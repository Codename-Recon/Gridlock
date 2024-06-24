class_name GlobalMessages
extends Node

signal action_done

var _reload_to_menu: bool = false

@onready var accept_dialog: AcceptDialog = $AcceptDialog
@onready var notification: Control = $Notification
@onready var notifications_list: VBoxContainer = $NotificationsList



func spawn(title: String, text: String, reload_to_menu: bool = false) -> void:
	accept_dialog.title = title
	accept_dialog.dialog_text = text
	accept_dialog.show()
	accept_dialog.position.x = round(
		get_viewport().get_visible_rect().size.x / 2.0 - accept_dialog.size.x / 2.0
	)
	accept_dialog.position.y = round(
		get_viewport().get_visible_rect().size.y / 2.0 - accept_dialog.size.x / 2.0
	)
	_reload_to_menu = reload_to_menu
	
func spawn_window(title: String, content: Node, buttons: Array[Button]) -> void:
	pass
	
func spawn_notification(title: String, buttons: Array[Button], timeout: int = 0) -> void:
	var notice: Control = notification.duplicate()
	notice.show()
	notifications_list.add_child(notice)


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
