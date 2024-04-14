class_name MapFile
extends Node

const MAP_VERSION: String = "1.0.0"
const MAP_SOURCE: String = "Codename: Recon Map Editor"
const MAP_GROUND_TILE_ID: String = "PLAIN_1"

static var _global: GlobalGlobal = Global

static func save_to_file(json_map: String, file_name: String) -> void:
	var packer: ZIPPacker = ZIPPacker.new()
	packer.open("%s/%s.crm" % [_global.MAP_CUSTOM_FOLDER_PATH, file_name])
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
	var dic: Dictionary = {}
	dic["version"] = MAP_VERSION
	dic["name"] = map.map_name
	dic["author"] = map.author
	dic["source"] = MAP_SOURCE
	dic["last_edited"] = Time.get_unix_time_from_system()
	
	var player_array: Array[Dictionary] = []
	for player: Player in map.players.get_children():
		player_array.append({"id": player.id, "money": player.money})
	dic["players"] = player_array
	dic["round"] = map.game_round
	
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
	dic["terrain"] = terrain_array
	
	return JSON.stringify(dic, "\t")


static func _serialize_unit(unit: Unit) -> Dictionary:
	var dic: Dictionary = {
		"id": unit.id,
		"health": unit.stats.health,
		"fuel": unit.stats.fuel,
		"ammo": unit.stats.ammo,
		"capturing": unit.stats.capturing,
		"hidden": unit.stats.map_hidden
	}
	
	dic["owner"] = 0
	if unit.player_owned:
		dic["owner"] = unit.player_owned.id
		
	var cargo_array: Array[Dictionary] = []
	if unit.cargo:
		for u: Unit in unit.cargo.get_children():
			cargo_array.append(_serialize_unit(u))
	dic["cargo"] = cargo_array
	
	return dic


static func _serialize_terrain(terrain: Terrain) -> Dictionary:
	var dic: Dictionary = {
		"id": terrain.id,
		"tile_id": terrain.tile_id,
		"health": terrain.stats.health,
		"capture_health": terrain.stats.capture_health,
		"ammo": terrain.stats.ammo,
		"ground_tile_id": MAP_GROUND_TILE_ID,
		"reverse_animation": false,
	}
	
	dic["unit"] = null
	if terrain.has_unit():
		dic["unit"] = _serialize_unit(terrain.get_unit())
		
	dic["owner"] = 0
	if terrain.player_owned:
		dic["owner"] = terrain.player_owned.id

	return dic
	
	
static func deserialize(json_map: String) -> Map:
	var dic: Dictionary = JSON.parse_string(json_map)
	var map: Map = Map.new()
	map.map_name = dic["name"]
	map.author = dic["author"]
	map.source = dic["source"]
	map.game_round = dic["round"]
	for player_dic: Dictionary in dic["players"]:
		var player: Player = Player.new()
		player.id = player_dic["id"]
		player.money = player_dic["money"]
		player.name = "PLAYER %s" % player.id
		map.players.add_child(player)
	for x: int in len(dic["terrain"]):
		for y: int in len(dic["terrain"][x]):
			var td: Dictionary = dic["terrain"][x][y]
			var pos: Vector2i = Vector2i(x, y) * ProjectSettings.get_setting("global/grid_size")
			var terrain_id: String = td["id"]
			var tile_id: String = td["tile_id"]
			var ground_tile_id: String = td["ground_tile_id"]
			var texture: Texture2D = MapEditor.get_texture_with_tile_id(tile_id)
			var ground_texture: Texture2D = MapEditor.get_texture_with_tile_id(ground_tile_id)
			var owner: int = td["owner"]
			map.create_terrain(terrain_id, tile_id, pos, texture, ground_texture, owner)
			if td.get("unit") != null:
				var ud: Dictionary = td["unit"]
				var unit_id: String = ud["id"]
				var unit_health: int = ud["health"]
				var unit_fuel: int = ud["fuel"]
				var unit_ammo: int = ud["ammo"]
				var unit_owner: int = ud["owner"]
				var unit_capturing: bool = ud["capturing"]
				var unit_hidden: bool = ud["hidden"]
				var unit: Unit = map.create_unit(unit_id, pos, unit_owner)
				unit.stats = unit.get_node("UnitStats")
				unit.stats.health = unit_health
				unit.stats.fuel = unit_fuel
				unit.stats.ammo = unit_ammo
				unit.stats.capturing = ud["capturing"]
				unit.stats.map_hidden = ud["hidden"]
				if unit.cargo:
					var cargo_dic: Array[Dictionary] = ud["cargo"]
					var cargo: Array[Unit] = []
					for uud: Dictionary in cargo_dic:
						unit.cargo.add_child(_deserialize_cargo(uud, map))
	return map


static func _deserialize_cargo(cargo_dic: Dictionary, map: Map) -> Unit:
	var cargo_id: String = cargo_dic["id"]
	var cargo_healt: int = cargo_dic["health"]
	var cargo_fuel: int = cargo_dic["fuel"]
	var cargo_ammo: int = cargo_dic["ammo"]
	var cargo_owner: int = cargo_dic["owner"]
	var cargo_capturing: bool = cargo_dic["capturing"]
	var cargo_hidden: bool = cargo_dic["hidden"]
	var unit_scene: PackedScene = Map.predefined_units_packed_scenes[cargo_id]
	var unit: Unit = unit_scene.instantiate()
	unit.id = cargo_id
	unit.stats.health = cargo_healt
	unit.stats.fuel = cargo_fuel
	unit.stats.ammo = cargo_ammo
	unit.stats.capturing = cargo_capturing
	unit.stats.map_hidden = cargo_hidden
	unit.player_owned = map.create_or_get_player(cargo_owner)
	return unit
