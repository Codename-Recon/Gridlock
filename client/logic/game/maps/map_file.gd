class_name MapFile
extends Node

const MAP_VERSION: String = "1.0.1"
const MAP_SOURCE: String = "Gridlock Map Editor"
const MAP_GROUND_TILE_ID: String = "PLAIN_1"

static var _global: GlobalGlobal = Global


static func save_to_file(json_map: String, file_name: String) -> void:
	var packer: ZIPPacker = ZIPPacker.new()
	packer.open("%s/%s.glm" % [_global.MAP_CUSTOM_FOLDER_PATH, file_name])
	packer.start_file("map.json")
	packer.write_file(json_map.to_utf8_buffer())
	packer.close_file()
	packer.close()


static func load_from_file(file_path: String) -> String:
	var reader: ZIPReader = ZIPReader.new()
	reader.open(file_path)
	var data: PackedByteArray = reader.read_file("map.json")
	reader.close()
	return data.get_string_from_utf8()


static func serialize(map: Map) -> String:
	var map_values: MapValues = MapValues.new()
	
	map_values.version = MAP_VERSION
	map_values.name = map.map_name
	map_values.author = map.author
	map_values.source = MAP_SOURCE
	map_values.last_edited = Time.get_unix_time_from_system()

	var player_array: Array[Dictionary] = []
	for player: Player in map.players.get_children():
		player_array.append(_serialize_player(player))
	map_values.players = player_array
	map_values.round = map.game_round

	# Create terrain array
	var _map_size: Vector2i = map.map_size
	var terrain_array: Array[Array] = []
	for x: int in _map_size.x:
		var terrain_column: Array[Dictionary] = []
		for y: int in _map_size.y:
			var pos: Vector2i = Vector2i(x, y) * ProjectSettings.get_setting("global/grid_size")
			var terrain: Terrain = map.get_terrain_by_position(pos)
			terrain_column.append(_serialize_terrain(terrain))
		terrain_array.append(terrain_column)
	map_values.terrain = terrain_array

	return JSON.stringify(inst_to_dict(map_values), "\t")


static func _serialize_player(player: Player) -> Dictionary:
	var player_values: PlayerValues = PlayerValues.new()
	player_values.id = player.id
	player_values.money = player.money
	player_values.team = player.team
	return inst_to_dict(player_values)


static func _serialize_unit(unit: Unit) -> Dictionary:
	var unit_values: UnitValues = UnitValues.new()
	unit_values.id = unit.id
	unit_values.health = unit.stats.health
	unit_values.fuel = unit.stats.fuel
	unit_values.ammo = unit.stats.ammo
	unit_values.capturing = unit.stats.capturing
	unit_values.hidden = unit.stats.map_hidden
	unit_values.owner = 0
	if unit.player_owned:
		unit_values.owner = unit.player_owned.id

	var cargo_array: Array[Dictionary] = []
	if unit.cargo:
		for u: Unit in unit.cargo.get_children():
			cargo_array.append(_serialize_unit(u))
	unit_values.cargo = cargo_array

	return inst_to_dict(unit_values)


static func _serialize_terrain(terrain: Terrain) -> Dictionary:
	var terrain_values: TerrainValues = TerrainValues.new()
	terrain_values.id = terrain.id
	terrain_values.tile_id = terrain.tile_id
	terrain_values.health = terrain.stats.health
	terrain_values.capture_health = terrain.stats.capture_health
	terrain_values.ammo = terrain.stats.ammo
	terrain_values.ground_tile_id = MAP_GROUND_TILE_ID
	terrain_values.reverse_animation = false

	if terrain.has_unit():
		terrain_values.unit = _serialize_unit(terrain.get_unit())

	terrain_values.owner = 0
	if terrain.player_owned:
		terrain_values.owner = terrain.player_owned.id

	return inst_to_dict(terrain_values)


static func deserialize(json_map: String) -> Map:
	var dic: Dictionary = JSON.parse_string(json_map)
	dic["@path"] = "res://logic/game/maps/map_file.gd"
	dic["@subpath"] = "MapValues"
	var map_values: MapValues = dict_to_inst(dic)
	map_values.fix()
	var map: Map = Map.new()
	map.map_name = map_values.name
	map.author = map_values.author
	map.source = map_values.source
	map.game_round = map_values.round
	for player_dic: Dictionary in map_values.players:
		player_dic["@path"] = "res://logic/game/maps/map_file.gd"
		player_dic["@subpath"] = "PlayerValues"
		var player_values: PlayerValues = dict_to_inst(player_dic)
		var player: Player = Player.new()
		player.id = player_values.id
		player.money = player_values.money
		player.team = player_values.team
		player.name = "PLAYER %s" % player.id
		map.players.add_child(player)
	for x: int in len(map_values.terrain):
		for y: int in len(map_values.terrain[x]):
			var td: Dictionary = map_values.terrain[x][y]
			td["@path"] = "res://logic/game/maps/map_file.gd"
			td["@subpath"] = "TerrainValues"
			var terrain_values: TerrainValues = dict_to_inst(td)
			var pos: Vector2i = Vector2i(x, y) * ProjectSettings.get_setting("global/grid_size")
			var tile_id: String = terrain_values.tile_id
			var ground_tile_id: String = terrain_values.ground_tile_id
			var texture: Texture2D = MapEditor.get_texture_with_tile_id(tile_id)
			var ground_texture: Texture2D = MapEditor.get_texture_with_tile_id(ground_tile_id)
			var terrain_data: MapEditor.TerrainData = MapEditor.get_data_with_tile_id(tile_id)
			map.create_terrain(terrain_values.id, tile_id, pos, terrain_data.tile_z_index, texture, ground_texture, terrain_values.owner)
			if terrain_values.unit:
				var ud: Dictionary = terrain_values.unit
				ud["@path"] = "res://logic/game/maps/map_file.gd"
				ud["@subpath"] = "UnitValues"
				var unit_values: UnitValues = dict_to_inst(ud)
				var unit: Unit = map.create_unit(unit_values.id, pos, unit_values.owner)
				unit.stats = unit.get_node("UnitStats")
				unit.stats.health = unit_values.health
				unit.stats.fuel = unit_values.fuel
				unit.stats.ammo = unit_values.ammo
				unit.stats.capturing = unit_values.capturing
				unit.stats.map_hidden = unit_values.hidden
				if unit.cargo:
					var cargo_dic: Array = unit_values.cargo
					var cargo: Array[Unit] = []
					for uud: Dictionary in cargo_dic:
						unit.cargo.add_child(_deserialize_cargo(uud, map))
	return map


static func _deserialize_cargo(cargo_dic: Dictionary, map: Map) -> Unit:
	cargo_dic.unit["@path"] = "res://logic/game/maps/map_file.gd"
	cargo_dic.unit["@subpath"] = "UnitValues"
	var unit_values: UnitValues = dict_to_inst(cargo_dic)
	var unit_scene: PackedScene = Map.predefined_units_packed_scenes[unit_values.id]
	var unit: Unit = unit_scene.instantiate()
	unit.id = unit_values.id
	unit.stats.health = unit_values.health
	unit.stats.fuel = unit_values.fuel
	unit.stats.ammo = unit_values.ammo
	unit.stats.capturing = unit_values.capturing
	unit.stats.map_hidden = unit_values.hidden
	unit.player_owned = map.create_or_get_player(unit_values.owner)
	return unit


class PlayerValues extends NumberFix:
	var id: int
	var money: int
	var team: int


class UnitValues extends NumberFix:
	var id: String
	var health: int
	var fuel: int
	var ammo: int
	var cargo: Array[Dictionary]
	var owner: int
	var capturing: bool
	var hidden: bool


class TerrainValues extends NumberFix:
	var id: String
	var tile_id: String
	var unit: Dictionary
	var health: int
	var capture_health: int
	var ammo: int
	var owner: int
	var ground_tile_id: String
	var reverse_animation: bool


class MapValues extends NumberFix:
	var version: String
	var name: String
	var last_edited: float
	var author: String
	var source: String
	var terrain: Array[Array]
	var players: Array[Dictionary]
	var round: int
