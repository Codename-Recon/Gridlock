## Class for selected element. Needs "Element" and a "SelectOverlay" both at least as Controls.
extends Control
class_name SelectableElement

signal selected
signal entered

@onready var _select_overlay: ColorRect = $SelectOverlay
var deactivated: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_select_overlay.hide()

func _process(delta: float) -> void:
	pass
	
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_first"):
		selected.emit()

func _on_mouse_entered() -> void:
	if not deactivated:
		entered.emit(self)
		_select_overlay.show()
	
func _on_mouse_exited() -> void:
	_select_overlay.hide()
