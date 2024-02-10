class_name ActionPanel
extends Panel
signal action_selected

var action_pressed: GameConst.Actions = GameConst.Actions.NONE


func _ready() -> void:
	hide()
	($VBoxContainer/ButtonMove as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.MOVE)
	)
	($VBoxContainer/ButtonAttack as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.ATTACK)
	)
	($VBoxContainer/ButtonEnter as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.ENTER)
	)
	($VBoxContainer/ButtonDeploy as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.DEPLOY)
	)
	($VBoxContainer/ButtonJoin as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.JOIN)
	)
	($VBoxContainer/ButtonSupply as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.REFILL)
	)
	($VBoxContainer/ButtonCapture as Button).pressed.connect(
		_button_pressed.bind(GameConst.Actions.CAPTURE)
	)


func _process(_delta: float) -> void:
	# keep it inside of parent
	if position.x + size.x > get_parent_control().size.x:
		position.x -= size.x
	if position.y + size.y > get_parent_control().size.y:
		position.y -= size.y


func set_buttons(actions: Array) -> void:
	if GameConst.Actions.MOVE in actions:
		($VBoxContainer/ButtonMove as Button).show()
	else:
		($VBoxContainer/ButtonMove as Button).hide()
	if GameConst.Actions.ATTACK in actions:
		($VBoxContainer/ButtonAttack as Button).show()
	else:
		($VBoxContainer/ButtonAttack as Button).hide()
	if GameConst.Actions.ENTER in actions:
		($VBoxContainer/ButtonEnter as Button).show()
	else:
		($VBoxContainer/ButtonEnter as Button).hide()
	if GameConst.Actions.DEPLOY in actions:
		($VBoxContainer/ButtonDeploy as Button).show()
	else:
		($VBoxContainer/ButtonDeploy as Button).hide()
	if GameConst.Actions.JOIN in actions:
		($VBoxContainer/ButtonJoin as Button).show()
	else:
		($VBoxContainer/ButtonJoin as Button).hide()
	if GameConst.Actions.REFILL in actions:
		($VBoxContainer/ButtonSupply as Button).show()
	else:
		($VBoxContainer/ButtonSupply as Button).hide()
	if GameConst.Actions.CAPTURE in actions:
		($VBoxContainer/ButtonCapture as Button).show()
	else:
		($VBoxContainer/ButtonCapture as Button).hide()


func _on_v_box_container_resized() -> void:
	size = ($VBoxContainer as BoxContainer).size


func _button_pressed(action: GameConst.Actions) -> void:
	action_pressed = action
	action_selected.emit()
	hide()
