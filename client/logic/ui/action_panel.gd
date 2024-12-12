class_name ActionPanel
extends Panel
signal action_selected

var action_pressed: GameConst.Actions = GameConst.Actions.NONE

var _buttons: Dictionary = {}

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var button_move: Button = $VBoxContainer/ButtonMove
@onready var button_attack: Button = $VBoxContainer/ButtonAttack
@onready var button_enter: Button = $VBoxContainer/ButtonEnter
@onready var button_deploy: Button = $VBoxContainer/ButtonDeploy
@onready var button_join: Button = $VBoxContainer/ButtonJoin
@onready var button_supply: Button = $VBoxContainer/ButtonSupply
@onready var button_capture: Button = $VBoxContainer/ButtonCapture


func _ready() -> void:
	hide()
	_buttons[GameConst.Actions.MOVE] = button_move
	_buttons[GameConst.Actions.ATTACK] = button_attack
	_buttons[GameConst.Actions.ENTER] = button_enter
	_buttons[GameConst.Actions.DEPLOY] = button_deploy
	_buttons[GameConst.Actions.JOIN] = button_join
	_buttons[GameConst.Actions.REFILL] = button_supply
	_buttons[GameConst.Actions.CAPTURE] = button_capture
	for action: GameConst.Actions in _buttons:
		var button: Button = _buttons[action]
		button.pressed.connect(_button_pressed.bind(action))


func _process(_delta: float) -> void:
	# keep it inside of parent
	if position.x + size.x > get_parent_control().size.x:
		position.x -= size.x
	if position.y + size.y > get_parent_control().size.y:
		position.y -= size.y


func set_buttons(actions: Array[GameConst.Actions]) -> void:
	_reset_size()
	for action: GameConst.Actions in _buttons:
		var button: Button = _buttons[action]
		if action in actions: 
			button.show()
		else:
			button.hide()
	_update_size.call_deferred()


func _button_pressed(action: GameConst.Actions) -> void:
	action_pressed = action
	action_selected.emit()
	hide()


func _reset_size() -> void:
	v_box_container.size.y = 0
	size.y = 0


func _update_size() -> void:
	size.y = v_box_container.size.y
	v_box_container.position = Vector2.ZERO
