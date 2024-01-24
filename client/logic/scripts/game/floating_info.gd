extends Node2D
class_name FloatingInfo
signal finished

@export var text: String:
	set(value):
		text = value

@export_color_no_alpha var color: Color:
	set(value):
		color = value

func _ready() -> void:
	var text_label: Label = %Text
	var sprite: Sprite2D = $Sprite2D
	text_label.text = text
	sprite.modulate.r = color.r
	sprite.modulate.g = color.g
	sprite.modulate.b = color.b
