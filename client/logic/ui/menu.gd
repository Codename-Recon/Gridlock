@tool
class_name Menu
extends Control

# @see https://github.com/godotengine/godot-proposals/issues/10139 for a proposal of how to improve
# this text translation, as it can be a problem when changing the language inside the game
@export var title: String = "Menu":
	set(value):
		($Label as Label).text = tr(value)
		title = tr(value)


func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
