extends Node
class_name GlobalMessages

signal action_done

@onready var accept_dialog: AcceptDialog = $AcceptDialog

var _reload_to_menu: bool = false

func spawn(title: String, text: String, reload_to_menu: bool = false) -> void:
	accept_dialog.title = title
	accept_dialog.dialog_text = text
	accept_dialog.show()
	accept_dialog.position.x = round(get_viewport().get_visible_rect().size.x / 2.0 - accept_dialog.size.x / 2.0)
	accept_dialog.position.y = round(get_viewport().get_visible_rect().size.y / 2.0 - accept_dialog.size.x / 2.0)
	_reload_to_menu = reload_to_menu

func _on_accept_dialog_confirmed() -> void:
	_do_action()
	action_done.emit()

func _on_accept_dialog_canceled() -> void:
	_do_action()
	action_done.emit()

func _do_action() -> void:
	if _reload_to_menu:
		_reload_to_menu = false
		get_tree().change_scene_to_file("res://levels/menu.tscn")
