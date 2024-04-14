class_name Selection
extends Sprite2D

signal selection_changed(terrain: Terrain)

var movement_enabled: bool = true
var last_mouse_position: Vector2i
var last_terrain: Terrain:
	get:
		if _current_move_tween.is_running():
			await _current_move_tween.finished
		return  _global.last_loaded_map.get_terrain_by_position(global_position)

@onready var _cursor: Cursor = $"../Cursor"
@onready var _current_move_tween: Tween

var _global: GlobalGlobal = Global

func is_mouse_still_inside() -> bool:
	return last_mouse_position == _cursor.get_tile_position()


func reset() -> void:
	
	if _global.last_loaded_map and _global.last_loaded_map.terrains.size() > 0:
		var terrain: Terrain = _global.last_loaded_map.terrains[0]
		last_mouse_position = Vector2(-1,-1)
		_move_selection(terrain)


func _process(delta: float) -> void:
	if not movement_enabled:
		return
	if _global.last_loaded_map and _global.last_loaded_map.terrains.size() > 0:
		if _global.last_loaded_map.get_terrain_by_position(_cursor.get_tile_position()):
			var terrain: Terrain =  _global.last_loaded_map.get_terrain_by_position(_cursor.get_tile_position())
			_move_selection(terrain)


func _move_selection(terrain: Terrain) -> void:
	# only update when mouse terrain has changed
	if terrain and last_mouse_position != _cursor.get_tile_position():
		_current_move_tween = create_tween()
		_current_move_tween.tween_property(self, "position", terrain.position, 0.05)
		last_mouse_position = _cursor.get_tile_position()
		selection_changed.emit(terrain)
