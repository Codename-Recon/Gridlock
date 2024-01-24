@tool
extends Control
class_name Menu

@export var title: String = "Menu":
	set(value):
		($Label as Label).text = tr(value)
		title = tr(value)

func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
