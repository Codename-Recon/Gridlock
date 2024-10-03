class_name GameButtonMenuSwitch
extends GameButton

@export var next_menu: Control
@export var parent_override: Control


func _pressed() -> void:
	super._pressed()
	if next_menu:
		if parent_override:
			parent_override.hide()
		else:
			(get_parent() as Control).hide()
		next_menu.show()
