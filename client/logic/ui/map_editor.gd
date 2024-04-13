class_name MapEditor
extends Node2D

signal tile_edit_selected(terrain: Terrain, unit: Unit)

enum Mode{
	TERRAIN,
	UNIT,
	TILE,
	REMOVE,
	EDIT
}

const TILES: TileSet = preload("res://assets/resources/game/tiles.tres")

@export var map_size: Vector2i = Vector2i(20, 20)
@export var game_input: GameInput
@export var map: Map

@onready var tile_map: TileMap = $TileMap

var _sound: GlobalSound = Sound
var _messages: GlobalMessages = Messages
var _terrain_id_lookup: Dictionary = {}
var _mode: Mode = Mode.TERRAIN
var _current_unit_id: String
var _current_unit_scene: PackedScene
var _current_terrain_set: int
var _current_terrain: int
var _current_tile_atlas_id: Vector2i
var _current_player_id: int = 0
var _tile_buffer: Dictionary = {}


static func get_texture_with_atlas_coords(atlas_coords: Vector2i) -> Texture2D:
	var source: TileSetAtlasSource = TILES.get_source(0)
	var rect: Rect2i = source.get_tile_texture_region(atlas_coords, 0)
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.set_atlas(source.texture)
	atlas.region = rect
	return atlas
	
	
static func get_texture_with_tile_id(tile_id: String) -> Texture2D:
	if tile_id == "":
		return null
	var source: TileSetAtlasSource = TILES.get_source(0)
	for i: int in source.get_tiles_count():
		var pos: Vector2i = source.get_tile_id(i)
		var current_tile_id: String = source.get_tile_data(pos, 0).get_custom_data("tile_id")
		if current_tile_id == tile_id:
			return get_texture_with_atlas_coords(pos)
	return null
	
	
static func get_data_with_altlas_coords(atlas_coords: Vector2i) -> Array[String]:
	var source: TileSetAtlasSource = TILES.get_source(0)
	var data: TileData = source.get_tile_data(atlas_coords, 0)
	return [data.get_custom_data("id"), data.get_custom_data("tile_id"), data.get_custom_data("ground_tile_id")]


func has_id_with_tile_coords(tile_coords: Vector2i) -> bool:
	var data: TileData = tile_map.get_cell_tile_data(0, tile_coords)
	return data != null


func _ready() -> void:
	for i: int in TILES.get_terrains_count(0):
		var tile_name: String = TILES.get_terrain_name(0, i)
		_terrain_id_lookup[tile_name] = i
	_init_map()
	game_input.position = to_global(tile_map.map_to_local(map_size / 2))
	game_input.selection.reset()


func _init_map() -> void:
	for i: int in range(map_size.x):
		for j: int in range(map_size.y):
			_place_terrain(Vector2i(i, j), 0, 1)


## Places tile and creates terrain node
func _place_terrain(cell: Vector2i, terrain_set: int, terrain: int) -> void:
	tile_map.set_cells_terrain_connect(0, [cell], terrain_set, terrain, false)
	_create_terrain_on_map(cell)


## Places a Unit in the map editor mode. 
## The return value indicates whether the unit can be placed at that specific location.
func _place_unit(unit_id: String, terrain_position: Vector2i) -> bool:
	return map.create_unit(unit_id, terrain_position, _current_player_id)


func _place_tile(cell: Vector2i, tile_atlas_coords: Vector2i) -> void:
	tile_map.set_cell(0, cell, 0, tile_atlas_coords)
	_create_terrain_on_map(cell)


func _create_terrain_on_map(cell: Vector2i) -> void:
	var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(0, cell)
	var texture: Texture2D = get_texture_with_atlas_coords(atlas_coords)
	var data: Array[String] = get_data_with_altlas_coords(atlas_coords)
	var ground_tile_id: String = data[2]
	var ground_texture: Texture2D = get_texture_with_tile_id(ground_tile_id)
	map.create_terrain(data[0], data[1], cell * tile_map.tile_set.tile_size, texture, ground_texture, _current_player_id)
	# Change terrains which got changed by auto tiling
	tile_map.update_internals()
	for changed_cell: Vector2i in _find_difference_with_main_tile_buffer():
		if changed_cell == cell:
			continue
		map.remove_terrain(changed_cell * tile_map.tile_set.tile_size)
		atlas_coords = tile_map.get_cell_atlas_coords(0, changed_cell)
		texture = get_texture_with_atlas_coords(atlas_coords)
		data = get_data_with_altlas_coords(atlas_coords)
		ground_tile_id = data[2]
		ground_texture = get_texture_with_tile_id(ground_tile_id)
		map.create_terrain(data[0], data[1], changed_cell * tile_map.tile_set.tile_size, texture, ground_texture, _current_player_id)
	_tile_buffer = _create_tile_buffer()


## Removes tile and terrain node
func _remove_terrain(cell: Vector2i, remove_tile: bool = true) -> void:
	if remove_tile:
		tile_map.set_cells_terrain_connect(0, [cell], 0, -1)
	map.remove_terrain(cell * tile_map.tile_set.tile_size)


func _create_tile_buffer() -> Dictionary:
	var buffer: Dictionary = {}
	var tiles: Array[Vector2i] = tile_map.get_used_cells(0)
	for tile: Vector2i in tiles:
		var id: int = hash(tile_map.get_cell_atlas_coords(0, tile))
		buffer[tile] = id
	return buffer


func _find_difference_with_main_tile_buffer() -> Dictionary:
	var buffer: Dictionary = _create_tile_buffer()
	var return_buffer: Dictionary = {}
	if buffer == _tile_buffer:
		return return_buffer
	for key: Vector2i in buffer:
		if _tile_buffer.has(key) and buffer[key] == _tile_buffer[key]:
			continue
		else:
			return_buffer[key] = buffer[key]
	return return_buffer


func _on_map_editor_ui_remove_selected() -> void:
	_mode = Mode.REMOVE


func _on_map_editor_ui_edit_selected() -> void:
	_mode = Mode.EDIT


func _on_game_input_dragging(terrain: Terrain) -> void:
	var cell: Vector2i = terrain.global_position
	cell = cell / tile_map.tile_set.tile_size
	match _mode:
		Mode.TERRAIN:
			_remove_terrain(cell, false)  # Don't remove tile, since it can mess up autotiling
			_place_terrain(cell, _current_terrain_set, _current_terrain)
		Mode.UNIT:
			if _place_unit(_current_unit_id, terrain.global_position):
				_sound.play("Drop2")
			else:
				_sound.play("Deselect")
		Mode.TILE:
			_remove_terrain(cell, false)  # Don't remove tile, since it can mess up autotiling
			_place_tile(cell, _current_tile_atlas_id)
		Mode.EDIT:
			_sound.play("Drop2")
			tile_edit_selected.emit(terrain, terrain.get_unit())
		Mode.REMOVE:
			map.remove_unit(terrain.global_position)
			_sound.play("Drop2")


func _on_ui_map_resized(new_size: Vector2i) -> void:
	for i: int in map_size.x:
		for j: int in map_size.y:
			_remove_terrain(Vector2i(i, j))
	
	for i: int in new_size.x:
		for j: int in new_size.y:
			_place_terrain(Vector2i(i, j), 0, 1)
	
	map_size = new_size
	game_input.selection.reset()


func _on_ui_terrain_selected(terrain_set: int, terrain: int) -> void:
	_mode = Mode.TERRAIN
	_current_terrain_set = terrain_set
	_current_terrain = terrain


func _on_ui_unit_selected(unit_id: String, unit_scene: PackedScene) -> void:
	_mode = Mode.UNIT
	_current_unit_id = unit_id
	_current_unit_scene = unit_scene


func _on_ui_tile_selected(atlas_id: Vector2i) -> void:
	_mode = Mode.TILE
	_current_tile_atlas_id = atlas_id

func _on_cursor_preview_set_terrain(coords: Vector2i) -> void:
	tile_map.set_cells_terrain_connect(0, [coords], _current_terrain_set, _current_terrain, false)


func _on_map_editor_ui_map_settings_player_id_changed(player_id: int) -> void:
	_current_player_id = player_id


func _on_map_editor_ui_save_selected() -> void:
	if map.map_name.is_empty():
		_messages.spawn(tr("MESSAGE_TITLE_MAP_EDITOR_SAVE_NO_NAME"), tr("MESSAGE_TEXT_MAP_EDITOR_SAVE_NO_NAME"))
		return
	var json_map: String = MapFile.serialize(map)
	MapFile.save_to_file(json_map, map.map_name)
