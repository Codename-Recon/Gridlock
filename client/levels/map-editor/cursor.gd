extends Node2D

signal set_terrain(coords: Vector2i)

@export var tile_map: TileMap


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var mouse_motion_event : InputEventMouse = event
		#print(mouse_motion_event)
		var coords : Vector2i = get_global_mouse_position()
		var grid_position: Vector2i = tile_map.local_to_map(tile_map.to_local(coords))
		if event is InputEventMouseMotion:
			
			# var mouse_pos : Vector2= mouse_motion_event.global_position
			#cursor.position = to_local(get_viewport().get_mouse_position())
			position = tile_map.to_global(tile_map.map_to_local(grid_position))
		elif event is InputEventMouseButton && event.is_action("select_first"):
			var cell : Array[Vector2i] = [grid_position]
			#cell.append(coords)
			emit_signal("set_terrain", grid_position)
			#tile_map.set_cells_terrain_connect(0, cell, 0, 2)
	if event is InputEventJoypadButton:
		print("Some joystick event")
