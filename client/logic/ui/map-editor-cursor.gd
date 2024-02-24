extends Node2D

signal set_terrain(coords: Vector2i)

@export var tile_map: TileMap

var _grid_position: Vector2i

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var mouse_motion_event : InputEventMouse = event
		var coords: Vector2i = get_global_mouse_position()
		_grid_position = tile_map.local_to_map(tile_map.to_local(coords))
		if event is InputEventMouseMotion:
			position = tile_map.to_global(tile_map.map_to_local(_grid_position))
		if Input.is_action_pressed("select_first"):
			set_terrain.emit(_grid_position)
	if event is InputEventJoypadButton:
		print("Some joystick event")
