class_name Cursor
extends Marker2D

func _process(delta: float) -> void:
	position = get_global_mouse_position()


func get_tile_position() -> Vector2i:
	var grid_size: int = ProjectSettings.get_setting("global/grid_size").y
	return round(position / grid_size) * grid_size
