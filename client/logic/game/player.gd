@icon("res://assets/images/icons/nodes/person-outline.svg")
@tool
class_name Player
extends Node

@export var id: int:
	set(value):
		color = ProjectSettings.get_setting("game/player_color")[value - 1]
		id = value

@export var input_type: GameConst.InputType = GameConst.InputType.HUMAN

@export var money: int = 0:
	set(value):
		money = value

@export var ai_difficulty: GameConst.AiDifficulty = GameConst.AiDifficulty.EASY

var color: Color


func _ready() -> void:
	color = ProjectSettings.get_setting("game/player_color")[id - 1]
