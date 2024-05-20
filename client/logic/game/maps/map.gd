@icon("res://assets/images/icons/nodes/layers-outline.svg")
@tool
class_name Map
extends Node2D

const DUPLICATE_TEST_SIZE: int = 4
const TERRAIN_STATS: PackedScene = preload("res://logic/ui/terrain_stats.tscn")

@export var map_name: String
@export var author: String
@export var source: String
@export var game_round: int = 0  # TODO: Implement this variable in the game instead of the local one in game script
@export_multiline var duplicate_result: String = ""

var players: Node
var terrains: Array[Terrain]
var units: Array[Unit]
var map_center: Vector2:
	get:
		var center: Vector2 = map_size - Vector2i.ONE
		center *= ProjectSettings.get_setting("global/grid_size") as Vector2
		center /= 2
		return center
var map_size: Vector2i:
	get:
		var max_x: int = 0
		var max_y: int = 0
		for n: Node in get_children():
			if n is Terrain:
				var terrain: Terrain = n
				if max_x < terrain.position.x:
					max_x = round(terrain.position.x)
				if max_y < terrain.position.y:
					max_y = round(terrain.position.y)
		return (
			Vector2i(max_x, max_y) / ProjectSettings.get_setting("global/grid_size") + Vector2i.ONE
		)

static var predefined_terrains_packed_scenes: Dictionary:
	get:
		if not predefined_terrains_packed_scenes:
			predefined_terrains_packed_scenes = _load_predefined_terrains_packed_scenes(
				_terrain_path
			)
		return predefined_terrains_packed_scenes
static var predefined_units_packed_scenes: Dictionary:
	get:
		if not predefined_units_packed_scenes:
			predefined_units_packed_scenes = _load_predefined_units_packed_scenes(_unit_path)
			print()
		return predefined_units_packed_scenes

static var _terrain_path: String = "res://logic/game/terrain/"
static var _unit_path: String = "res://logic/game/units/"

var _types: GlobalTypes = Types
var _global: GlobalGlobal = Global
var _players_node: Node
var _terrain_lookup: Dictionary


static func _load_predefined_terrains_packed_scenes(path: String) -> Dictionary:
	var _predefines: Dictionary = {}
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		push_error("Can not open directory: " + path)
	for file_name: String in dir.get_files():
		if file_name.ends_with(".tscn.remap"):
			file_name = file_name.trim_suffix(".remap")
		if not file_name.ends_with(".tscn"):
			continue
		var terrain_packed_scene: PackedScene = load(path + file_name) as PackedScene
		var terrain: Terrain = terrain_packed_scene.instantiate()
		_predefines[terrain.tile_id] = terrain_packed_scene
		terrain.queue_free()
	return _predefines


static func _load_predefined_units_packed_scenes(path: String) -> Dictionary:
	var _predefines: Dictionary = {}
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		push_error("Can not open directory: " + path)
	for file_name: String in dir.get_files():
		if file_name.ends_with(".tscn.remap"):
			file_name = file_name.trim_suffix(".remap")
		if not file_name.ends_with(".tscn"):
			continue
		var unit_packed_scene: PackedScene = load(path + file_name) as PackedScene
		var unit: Unit = unit_packed_scene.instantiate()
		_predefines[unit.id] = unit_packed_scene
		unit.queue_free()
	return _predefines


func has_player(player_id: int) -> bool:
	return players.get_children().any(func(p: Player) -> bool: return p.id == player_id)


func has_terrain_or_unit_owned_by_player(player_id: int) -> bool:
	if not has_player(player_id):
		return false
	for c: Node in get_children():
		if c is Terrain:
			var terrain: Terrain = c
			if terrain.player_owned and terrain.player_owned.id == player_id:
				return true
			if terrain.has_unit():
				if (
					terrain.get_unit().player_owned
					and terrain.get_unit().player_owned.id == player_id
				):
					return true
	return false


func create_or_get_player(player_id: int) -> Player:
	if player_id == 0:
		return null
	if has_player(player_id):
		return get_player(player_id)
	var player: Player = Player.new()
	player.id = player_id
	player.name = "PLAYER %s" % player_id
	players.add_child(player)
	return player


func get_player(player_id: int) -> Player:
	if not has_player(player_id) or player_id == 0:
		return null
	return players.get_children().filter(func(p: Player) -> bool: return p.id == player_id)[0]


func get_terrain_by_position(pos: Vector2i) -> Terrain:
	return _terrain_lookup.get(pos)


func remove_player(player_id: int) -> void:
	if not has_player(player_id):
		return
	var player: Player = get_player(player_id)
	players.remove_child(player)
	player.queue_free()


## Creats a terrain and updates the players
func create_terrain(
	id: String,
	tile_id: String,
	terrain_position: Vector2i,
	terrain_z_index: int,
	texture: Texture2D,
	ground_tile_texture: Texture2D,
	player_id: int
) -> void:
	# Check if predefined terrain exist. If not -> create terrain
	var terrain: Terrain
	if tile_id in Map.predefined_terrains_packed_scenes:
		var terrain_scene: PackedScene = Map.predefined_terrains_packed_scenes[tile_id]
		terrain = terrain_scene.instantiate()
	else:
		if not texture:
			push_error("Can not create terrain %s without texture " % id)
			return
		terrain = Terrain.new()
		terrain.id = id
		terrain.tile_id = tile_id
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "Sprite2D"
		terrain.add_child(sprite)
		terrain.sprite = sprite
		terrain.sprite.texture = texture
		terrain.sprite.z_index = terrain_z_index
	# Add ground tile if specified in the tile set
	if ground_tile_texture:
		var ground_sprite: Sprite2D = Sprite2D.new()
		ground_sprite.name = "Ground"
		terrain.add_child(ground_sprite)
		terrain.move_child(ground_sprite, 0)
		ground_sprite.texture = ground_tile_texture
	# Add terrain stats
	terrain.add_child(TERRAIN_STATS.instantiate())
	# Add player
	if terrain.values.can_capture:
		var player: Player = create_or_get_player(player_id)
		terrain.player_owned = player
	add_child(terrain)
	terrain.name = id
	terrain.position = terrain_position
	_terrain_lookup[terrain_position] = terrain


## Creats a unit on a specific terrain and updates the players. If a unit is already on that terrain, it will be replaced with the new unit.
## The return value is the unit iself. It also indicates whether the unit can be placed at that specific location (null when not possible).
func create_unit(id: String, terrain_position: Vector2i, player_id: int) -> Unit:
	var terrain: Terrain = get_terrain_by_position(terrain_position)
	if terrain:
		if terrain.has_unit():
			remove_unit(terrain.position)
		var unit_packed_scene: PackedScene = Map.predefined_units_packed_scenes[id]
		var unit: Unit = unit_packed_scene.instantiate()
		var movement_type: String = _types.movement_types[unit.values.movement_type]
		var movement_value: int = _types.movements[terrain.id]["CLEAR"][movement_type]
		# If unit is not allowed to be placed here
		if movement_value == 0:
			unit.queue_free()
			return null
		# Add player
		var player: Player = create_or_get_player(player_id)
		unit.player_owned = player
		terrain.add_child(unit)
		return unit
	return null


func change_terrain_owner(terrain: Terrain, player_id: int) -> void:
	var old_player: Player = terrain.player_owned
	terrain.player_owned = create_or_get_player(player_id)
	if old_player and not has_terrain_or_unit_owned_by_player(old_player.id):
		remove_player(old_player.id)


func change_unit_owner(unit: Unit, player_id: int) -> void:
	var old_player: Player = unit.player_owned
	unit.player_owned = create_or_get_player(player_id)
	if old_player and not has_terrain_or_unit_owned_by_player(old_player.id):
		remove_player(old_player.id)


## Removes a terrain and updates the players
func remove_terrain(terrain_position: Vector2i) -> void:
	var terrain: Terrain = get_terrain_by_position(terrain_position)
	if terrain:
		if terrain.has_unit():
			remove_unit(terrain.position)
		# Remove terrain and also remove player if no other entities are owned by it
		var player: Player = terrain.player_owned
		var terrain_pos: Vector2i = terrain.position
		_terrain_lookup.erase(terrain_pos)
		remove_child(terrain)
		terrain.queue_free()
		if player and not has_terrain_or_unit_owned_by_player(player.id):
			remove_player(player.id)


## Removes a unit and updates the players
func remove_unit(unit_position: Vector2i) -> void:
	var terrain: Terrain = get_terrain_by_position(unit_position)
	if terrain and terrain.has_unit():
		# Remove unit and also remove player if no other entities are owned by it
		var unit: Unit = terrain.get_unit()
		var player: Player = unit.player_owned
		terrain.remove_child(unit)
		unit.queue_free()
		if player and not has_terrain_or_unit_owned_by_player(player.id):
			remove_player(player.id)


func sort_terrain_by_position() -> void:
	var x_size: int = map_size.x
	var sort: Callable = func sort(a: Node, b: Node) -> bool:
		var terrain_a: Terrain = a
		var terrain_b: Terrain = b
		var value_a: int = terrain_a.position.y * x_size + terrain_a.position.x
		var value_b: int = terrain_b.position.y * x_size + terrain_b.position.x
		return value_a < value_b
	var children: Array[Node] = get_children().filter(func(e: Node) -> bool: return e is Terrain)
	children.sort_custom(sort)
	for i: int in children.size():
		move_child(children[i], i)

func _ready() -> void:
	if not Engine.is_editor_hint():
		if not has_node("Players"):
			_players_node = Node.new()
			_players_node.name = "Players"
			add_child(_players_node)
			players = _players_node
		else:
			players = get_node("Players")
		_sort_players()
		_global.last_loaded_map = self


func _init() -> void:
	_players_node = Node.new()
	_players_node.name = "Players"
	add_child(_players_node)
	players = _players_node


func _sort_players() -> void:
	var player_array: Array[Player] = []
	for player: Player in players.get_children():
		player_array.append(player)
		players.remove_child(player)
	player_array.sort_custom(func(a: Player, b: Player) -> bool: return a.id < b.id)
	for player: Player in player_array:
		players.add_child(player)
