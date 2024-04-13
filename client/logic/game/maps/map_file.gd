class_name MapFile
extends Node

const MAP_VERSION: String = "1.0.0"
const MAP_SOURCE: String = "Codename: Recon Map Editor"
const MAP_GROUND_TILE_ID: String = "PLANE_1"

static var _global: GlobalGlobal = Global

static func save_to_file(json_map: String, file_name: String) -> void:
	var packer: ZIPPacker = ZIPPacker.new()
	packer.open("%s/%s.crm" % [_global.MAP_CUSTOM_FOLDER_PATH, file_name])
	packer.start_file("map.json")
	packer.write_file(json_map.to_utf8_buffer())
	packer.close_file()
	packer.close()


static func serialize(map: Map) -> String:
	var dic: Dictionary = {}
	dic["version"] = MAP_VERSION
	dic["name"] = map.map_name
	dic["author"] = map.author
	dic["source"] = MAP_SOURCE
	
	var player_array: Array[Dictionary] = []
	for player: Player in map.players.get_children():
		player_array.append({"id": player.id, "money": player.money})
	dic["players"] = player_array
	dic["round"] = 0
	
	# Create terrain array
	var _map_size: Vector2i = map.map_size
	var terrain_array: Array[Array] = []
	var tmp_terrain: Terrain = map.get_tree().get_nodes_in_group("terrain")[0]
	for x: int in _map_size.x:
		var terrain_column: Array[Dictionary] = []
		for y: int in _map_size.y:
			var pos: Vector2i = Vector2i(x, y) * ProjectSettings.get_setting("global/grid_size")
			var terrain: Terrain = tmp_terrain.get_terrain_by_position(pos)
			terrain_column.append(_serialize_terrain(terrain))
		terrain_array.append(terrain_column)
	dic["terrain"] = terrain_array
	
	return JSON.stringify(dic)


static func _serialize_unit(unit: Unit) -> Dictionary:
	var dic: Dictionary = {
		"id": unit.id,
		"health": unit.stats.health,
		"fuel": unit.stats.fuel,
		"ammo": unit.stats.ammo,
		"capturing": unit.stats.capturing,
		"hidden": unit.stats.map_hidden
	}
	
	dic["owner"] = null
	if unit.player_owned:
		dic["owner"] = unit.player_owned.id
		
	var cargo_array: Array[Dictionary] = []
	if unit.cargo:
		for u: Unit in unit.cargo.get_children():
			cargo_array.append(_serialize_unit(u))
	dic["carrying"] = cargo_array
	
	return dic


static func _serialize_terrain(terrain: Terrain) -> Dictionary:
	var dic: Dictionary = {
		"id": terrain.id,
		"tile_id": terrain.tile_id,
		"health": terrain.stats.health,
		"capture_health": terrain.stats.capture_health,
		"ammo": terrain.stats.ammo,
		"ground_tile_id": MAP_GROUND_TILE_ID,
		"reverse_animation": false
	}
	dic["unit"] = null
	if terrain.has_unit():
		dic["unit"] = _serialize_unit(terrain.get_unit())

	return dic
	
	
