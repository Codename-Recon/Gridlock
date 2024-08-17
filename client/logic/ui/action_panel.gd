class_name ActionPanel
extends Panel
signal action_selected

var action_pressed: GameConst.Actions = GameConst.Actions.NONE

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
	button_move.pressed.connect(_button_pressed.bind(GameConst.Actions.MOVE))
	button_attack.pressed.connect(_button_pressed.bind(GameConst.Actions.ATTACK))
	button_enter.pressed.connect(_button_pressed.bind(GameConst.Actions.ENTER))
	button_deploy.pressed.connect(_button_pressed.bind(GameConst.Actions.DEPLOY))
	button_join.pressed.connect(_button_pressed.bind(GameConst.Actions.JOIN))
	button_supply.pressed.connect(_button_pressed.bind(GameConst.Actions.REFILL))
	button_capture.pressed.connect(_button_pressed.bind(GameConst.Actions.CAPTURE))


func _process(_delta: float) -> void:
	# keep it inside of parent
	if position.x + size.x > get_parent_control().size.x:
		position.x -= size.x
	if position.y + size.y > get_parent_control().size.y:
		position.y -= size.y


func set_buttons(actions: Array) -> void:
	if GameConst.Actions.MOVE in actions:
		button_move.show()
	else:
		button_move.hide()
	if GameConst.Actions.ATTACK in actions:
		button_attack.show()
	else:
		button_attack.hide()
	if GameConst.Actions.ENTER in actions:
		button_enter.show()
	else:
		button_enter.hide()
	if GameConst.Actions.DEPLOY in actions:
		button_deploy.show()
	else:
		button_deploy.hide()
	if GameConst.Actions.JOIN in actions:
		button_join.show()
	else:
		button_join.hide()
	if GameConst.Actions.REFILL in actions:
		button_supply.show()
	else:
		button_supply.hide()
	if GameConst.Actions.CAPTURE in actions:
		button_capture.show()
	else:
		button_capture.hide()


func _on_v_box_container_resized() -> void:
	size.y = ($VBoxContainer as BoxContainer).size.y


func _button_pressed(action: GameConst.Actions) -> void:
	action_pressed = action
	action_selected.emit()
	hide()
