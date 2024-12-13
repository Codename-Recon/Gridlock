class_name GameInput
extends Camera2D

signal input_first_triggered(terrain: Terrain)
signal input_second_triggered(terrain: Terrain)
signal input_dragged(terrain: Terrain)
signal input_escape_triggered
signal selection_moved(terrain: Terrain)

enum SelectionType { DEFAULT, ATTACK }

const ZOOM_RESOLUTION: int = 128  # should be a base 2 number to prevent texture bleeding

@onready var cursor: Cursor = $Decouple/Cursor
@onready var selection: Selection = $Decouple/Selection

var is_just_first: bool = false:
	get:
		var return_value: bool = is_just_first
		is_just_first = false
		return return_value
var is_just_second: bool = false:
	get:
		var return_value: bool = is_just_second
		is_just_second = false
		return return_value
var is_just_escape: bool = false:
	get:
		var return_value: bool = is_just_escape
		is_just_escape = false
		return return_value
var input_enabled: bool = true:
	set(value):
		input_enabled = value
		if value:
			cursor.show()
			selection.show()
		else:
			cursor.hide()
			selection.hide()
var zoom_enabled: bool = true
var camera_movement_enabled: bool = true
var button_enabled: bool = true
var selection_enabled: bool = true
var first_enabled: bool = true
var selection_movement_enabled: bool = true:
	set(value):
		selection_movement_enabled = value
		selection.movement_enabled = value

var _target_camera_zoom: Vector2
var _camera_move_speed: float
var _camera_zoom_speed: float
var _camera_max_zoom: float
var _camera_min_zoom: float
var _edge_scroll_zone: int


func enable_all() -> void:
	input_enabled = true
	zoom_enabled = true
	camera_movement_enabled = true
	button_enabled = true
	selection_movement_enabled = true
	first_enabled = true


func set_selection(type: SelectionType) -> void:
	selection.animation = str(SelectionType.keys()[type]).to_lower()


func _ready() -> void:
	_target_camera_zoom = zoom
	_camera_move_speed = ProjectSettings.get_setting("global/input/camera_move_speed")
	_camera_zoom_speed = ProjectSettings.get_setting("global/input/camera_zoom_speed")
	_camera_max_zoom = ProjectSettings.get_setting("global/input/camera_max_zoom")
	_camera_min_zoom = ProjectSettings.get_setting("global/input/camera_min_zoom")
	_edge_scroll_zone = ProjectSettings.get_setting("global/input/edge_scroll_zone")
	set_selection(SelectionType.DEFAULT)


func _process(delta: float) -> void:
	if not input_enabled:
		return
	_handle_camera_input(delta)
	_handle_edge_scrolling(delta)


func _handle_edge_scrolling(delta: float) -> void:
	var rect: Rect2 = get_window().get_visible_rect()
	var mouse: Vector2 = get_window().get_mouse_position()
	if camera_movement_enabled and rect.has_point(mouse):
		# Check if mouse is near screen edges
		if mouse.x < _edge_scroll_zone:  # Left edge
			_scroll_camera(delta, Vector2.LEFT)
		elif mouse.x > rect.size.x - _edge_scroll_zone: # Right edge
			_scroll_camera(delta, Vector2.RIGHT)
		if mouse.y < _edge_scroll_zone: # Top edge
			_scroll_camera(delta, Vector2.UP)
		elif mouse.y > rect.size.y - _edge_scroll_zone: # Bottom edge
			_scroll_camera(delta, Vector2.DOWN)


func _handle_camera_input(delta: float) -> void:
	if camera_movement_enabled:
		if Input.is_action_pressed("move_up"):
			_scroll_camera(delta, Vector2.UP)
		if Input.is_action_pressed("move_down"):
			_scroll_camera(delta, Vector2.DOWN)
		if Input.is_action_pressed("move_left"):
			_scroll_camera(delta, Vector2.LEFT)
		if Input.is_action_pressed("move_right"):
			_scroll_camera(delta, Vector2.RIGHT)


func _scroll_camera(delta: float, direction: Vector2) -> void:
	match direction:
		Vector2.UP:
			global_translate(Vector2.UP * delta * _camera_move_speed)
		Vector2.DOWN:
			global_translate(Vector2.DOWN * delta * _camera_move_speed)
		Vector2.LEFT:
			global_translate(Vector2.LEFT * delta * _camera_move_speed * 1.5)
		Vector2.RIGHT:
			global_translate(Vector2.RIGHT * delta * _camera_move_speed * 1.5)


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if button_enabled:
		if selection_enabled:
			if first_enabled and event.is_action_pressed("select_first"):
				is_just_first = true
				input_first_triggered.emit(await selection.last_terrain)
				if selection.is_mouse_still_inside():
					input_dragged.emit(await selection.last_terrain)
			if event.is_action_pressed("select_second"):
				is_just_second = true
				input_second_triggered.emit(await selection.last_terrain)
		if event.is_action_pressed("escape"):
			is_just_escape = true
			input_escape_triggered.emit()
	if zoom_enabled:
		if event.is_action_pressed("zoom_out") and _target_camera_zoom.x > _camera_min_zoom:
			var tween: Tween = create_tween()
			_target_camera_zoom = zoom - _camera_zoom_speed * Vector2.ONE
			tween.tween_property(
				self, "zoom", round(_target_camera_zoom * ZOOM_RESOLUTION) / ZOOM_RESOLUTION, 0.1
			)
		if event.is_action_pressed("zoom_in") and _target_camera_zoom.x < _camera_max_zoom:
			var tween: Tween = create_tween()
			_target_camera_zoom = zoom + _camera_zoom_speed * Vector2.ONE
			tween.tween_property(
				self, "zoom", round(_target_camera_zoom * ZOOM_RESOLUTION) / ZOOM_RESOLUTION, 0.1
			)


func _on_selection_changed(terrain: Terrain) -> void:
	selection_moved.emit(terrain)
	if (
		button_enabled
		and first_enabled
		and Input.is_action_pressed("select_first")
		and selection.is_mouse_still_inside()
	):
		input_dragged.emit(terrain)
