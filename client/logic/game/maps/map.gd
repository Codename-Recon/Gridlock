@icon("res://assets/images/icons/nodes/layers-outline.svg")
@tool
class_name Map
extends Node2D

const DUPLICATE_TEST_SIZE: int = 4


@export var map_name: String
@export var creator: String
@export var creator_url: String
@export var players: Array[Player]
@export_group("Tool")
@export var test_duplicates: bool:
	set(value):
		_test_for_duplicates()
@export_multiline var duplicate_result: String = ""

var _players_node: Node
var _terrain_path: String = "res://logic/game/terrain/"
var _predefined_terrains: Dictionary


func create_terrain(id: String, tile_id: String, terrain_position: Vector2i, texture: Texture2D) -> void:
	# Check if predefined terrain exist. If not -> create terrain
	var terrain: Terrain
	if tile_id in _predefined_terrains:
		terrain = _predefined_terrains[tile_id]
		terrain = terrain.duplicate()
	else:
		if not texture:
			push_error("Can not create terrain %s without texture " % id)
			return
		terrain = Terrain.new()
		terrain.id = id
		terrain.tile_id = id
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "Sprite2D"
		terrain.add_child(sprite)
		terrain.sprite = sprite
		terrain.sprite.texture = texture
	add_child(terrain)
	terrain.position = terrain_position


func remove_terrain(terrain_position: Vector2i) -> void:
	var tmp_terrain: Terrain = get_tree().get_nodes_in_group("terrain")[0]
	var terrain: Terrain = tmp_terrain.get_terrain_by_position(terrain_position)
	if terrain:
		terrain.queue_free()


func _ready() -> void:
	# Load predefined terrains
	_predefined_terrains = {}
	var dir: DirAccess = DirAccess.open(_terrain_path)
	if not dir:
		push_error("Can not open directory: " + _terrain_path)
	for file_name: String in dir.get_files():
		if not ".tscn" in file_name:
			continue
		var terrain: Terrain = (load(_terrain_path + file_name) as PackedScene).instantiate()
		_predefined_terrains[terrain.tile_id] = terrain
	if not Engine.is_editor_hint():
		if has_node("Players"):
			_players_node = get_node("Players")
			for player: Player in _players_node.get_children():
				players.append(player)
		else:
			_players_node = Node.new()
			_players_node.name = "Players"
			add_child(_players_node)


func _test_for_duplicates() -> void:
	var found_duplicates: bool = false
	duplicate_result = ""
	for child: Node in get_children():
		if is_instance_of(child, Terrain):
			var terrain: Terrain = child as Terrain
			var result: Array[Node] = get_children().filter(func(x: Node) -> bool: 
				var length_squared: float = ((x as Terrain).global_position - terrain.global_position).length_squared()
				return x != terrain and is_instance_of(x, Terrain)	and length_squared < DUPLICATE_TEST_SIZE)
			for r: Terrain in result:
				duplicate_result += str(r) + "\n"
				found_duplicates = true
	if not found_duplicates:
		duplicate_result = "No duplicates found (%s)" % Time.get_datetime_string_from_system()
