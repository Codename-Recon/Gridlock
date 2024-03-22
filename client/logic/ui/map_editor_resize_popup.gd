extends Panel

@onready var horizontal_control: HSlider = $VBoxContainer/Horizontal
@onready var vertical_control: HSlider = $VBoxContainer/Vertical
@onready var horizontal_label: Label = $VBoxContainer/HorizontalSize
@onready var vertical_label: Label = $VBoxContainer/VerticalSize

var new_size: Vector2i = Vector2i(20, 20)


func _on_accept_pressed() -> void:
	# This is the code I used in my project, it's expecting to be used with the map-editor-ui
	owner.emit_signal("resize_map", new_size)
	hide()


func _on_cancel_pressed() -> void:
	hide()


func _on_horizontal_value_changed(value: float) -> void:
	new_size.x = value
	horizontal_label.text = "%.0f" % value


func _on_vertical_value_changed(value: float) -> void:
	new_size.y = value
	vertical_label.text = "%.0f" % value
