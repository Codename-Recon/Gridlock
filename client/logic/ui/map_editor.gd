extends Node2D

@export var map_size: Vector2i = Vector2i(30, 30)
@export var camera: Camera2D
@export var map: Map

@onready var tile_map: TileMap = $TileMap

var current_terrain_set: int
var current_terrain: int


func _ready() -> void:
	_init_map()
	camera.position = to_global(tile_map.map_to_local(map_size / 2))


func _init_map() -> void:
	var all_cells: Array[Vector2i] = []
	for i: int in range(map_size.x):
		for j: int in range(map_size.y):
			all_cells.append(Vector2i(i, j))
	_place_terrain(all_cells, 0, 1)


func _on_ui_select_terrain(terrain_set: int, terrain: int) -> void:
	current_terrain_set = terrain_set
	current_terrain = terrain


func _on_cursor_preview_set_terrain(coords: Vector2i) -> void:
	tile_map.set_cells_terrain_connect(0, [coords], current_terrain_set, current_terrain, false)


func _on_ui_resize_map(new_size: Vector2i) -> void:
	var cells_to_paint: Array[Vector2i] = []
	var cells_to_drop: Array[Vector2i] = []
	
	for i: int in map_size.x:
		for j: int in map_size.y:
			cells_to_drop.append(Vector2i(i, j))
	_remove_terrain(cells_to_drop)
	
	for i: int in new_size.x:
		for j: int in new_size.y:
			cells_to_paint.append(Vector2i(i, j))
	_place_terrain(cells_to_paint, 0, 1)
	
	map_size = new_size


## Places tile and creates terrain node
func _place_terrain(cells: Array[Vector2i], terrain_set: int, terrain: int) -> void:
	tile_map.set_cells_terrain_connect(0, cells, terrain_set, terrain, false)
	tile_map.update_internals()
	for cell: Vector2i in cells:
		var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(0, cell)
		var texture: Texture2D = Map.get_texture_with_atlas_coords(0, atlas_coords)
		map.create_terrain("", "", cell * tile_map.tile_set.tile_size, texture)


## Removes tile and terrain node
func _remove_terrain(cells: Array[Vector2i]) -> void:
	tile_map.set_cells_terrain_connect(0, cells, 0, -1)
	for cell: Vector2i in cells:
		map.remove_terrain(cell * tile_map.tile_set.tile_size)
