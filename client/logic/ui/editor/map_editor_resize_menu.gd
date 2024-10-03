extends Menu

@onready var horizontal_control: HSlider = $VBoxContainer/Horizontal
@onready var vertical_control: HSlider = $VBoxContainer/Vertical
@onready var horizontal_label: Label = $VBoxContainer/HorizontalSize
@onready var vertical_label: Label = $VBoxContainer/VerticalSize

var new_size: Vector2i = Vector2i(20, 20)


func _on_accept_pressed() -> void:
	owner.emit_signal("map_resized", new_size)


func _on_cancel_pressed() -> void:
	hide()


func _on_horizontal_value_changed(value: float) -> void:
	new_size.x = round(value)
	horizontal_label.text = "%.0f" % round(value)


func _on_vertical_value_changed(value: float) -> void:
	new_size.y = round(value)
	vertical_label.text = "%.0f" % round(value)
