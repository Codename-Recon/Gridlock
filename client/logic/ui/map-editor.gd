@tool
extends Node2D

@export var map_size: Vector2i = Vector2i(30,30)
@export var camera: Camera2D

@onready var tile_map: TileMap = $TileMap
@onready var cursor: Node2D = $CursorPreview

var current_terrain_set: int
var current_terrain: int


func _ready() -> void:
	_on_menu_button_down()
	camera.position = to_global(tile_map.map_to_local(map_size/2))
	

func _on_menu_button_down() -> void:
	var all_cells: Array[Vector2i] = []
	for i: int in range( map_size.x):
		for j: int in range(map_size.y):
			all_cells.append(Vector2i(i, j))
	tile_map.set_cells_terrain_connect(0,all_cells, 0, 1)


func _on_ui_select_terrain(terrain_set: int, terrain: int) -> void:
	current_terrain_set = terrain_set
	current_terrain = terrain


func _on_cursor_preview_set_terrain(coords: Vector2i) -> void:
	tile_map.set_cells_terrain_connect(0, [coords], current_terrain_set, current_terrain, false)
