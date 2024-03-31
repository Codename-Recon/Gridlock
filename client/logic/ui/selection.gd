class_name Selection
extends Sprite2D

signal selection_changed(terrain: Terrain)

var movement_enabled: bool = true
var last_mouse_position: Vector2i
var last_terrain: Terrain:
	get:
		var temp_terrain: Terrain = get_tree().get_nodes_in_group("terrain")[0]
		if _current_move_tween.is_running():
			await _current_move_tween.finished
		return  temp_terrain.get_terrain_by_position(global_position)

@onready var _cursor: Cursor = $"../Cursor"
@onready var _current_move_tween: Tween


func _process(delta: float) -> void:
	if not movement_enabled:
		return
	if get_tree().has_group("terrain") and get_tree().get_nodes_in_group("terrain").size() > 0:
		var temp_terrain: Terrain = get_tree().get_nodes_in_group("terrain")[0]
		if temp_terrain.get_terrain_by_position(_cursor.get_tile_position()):
			var terrain: Terrain =  temp_terrain.get_terrain_by_position(_cursor.get_tile_position())
			# only update when mouse terrain has changed
			if terrain and last_mouse_position != _cursor.get_tile_position():
				_current_move_tween = create_tween()
				_current_move_tween.tween_property(self, "position", terrain.position, 0.05)
				selection_changed.emit(terrain)
				last_mouse_position = _cursor.get_tile_position()
