@tool
extends Button

@export var icon_name: String:
	set(new_value):
		icon_name = new_value
		update_icon()
@export var theme_type: String:
	set(new_value):
		theme_type = new_value
		update_icon()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_icon()

func update_icon() -> void:
	icon = ThemeDB.get_project_theme().get_icon(icon_name, theme_type)
