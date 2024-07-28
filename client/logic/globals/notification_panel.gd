extends Panel

class_name NotificationPanel

@export var title: String:
	set(new_text):
		title = new_text
		if title_label:
			update_title()

@export var actions: Array[Button]:
	set(new_actions):
		if new_actions.size() > 3:
			print("Warning: notifications will not show correctly with more than 3 buttons")
		actions = new_actions
		if actions_container:
			update_actions()

@export var timeout: int

@onready var title_label: Label = $Title

@onready var actions_container: HBoxContainer = $Actions

@onready var timer: Timer = $Timer


func _ready() -> void:
	update_title()
	update_actions()
	if timeout > 0:
		timer.wait_time = float(timeout)
		timer.start()


func update_title() -> void:
	title_label.text = title


func update_actions() -> void:
	for child: Node in actions_container.get_children():
		actions_container.remove_child(child)
	for action: Button in actions:
		actions_container.add_child(action)
	if actions.size() > 1:
		for pos: int in range(actions.size() - 1):
			var empty_container: Control = Control.new()
			empty_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			actions_container.add_child(empty_container)
			actions_container.move_child(empty_container, pos * 2 + 1)


func close() -> void:
	queue_free()


func _on_close_pressed() -> void:
	close()


func _on_timer_timeout() -> void:
	close()
