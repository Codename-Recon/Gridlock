@icon("res://assets/images/icons/nodes/person-outline.svg")
class_name Player
extends Node

var id: int:
	set(value):
		color = ProjectSettings.get_setting("game/player_color")[value - 1]
		id = value

var money: int = 0
var team: int = 0
var input_type: GameConst.InputType = GameConst.InputType.HUMAN
var ai_difficulty: GameConst.AiDifficulty = GameConst.AiDifficulty.EASY
var color: Color


func _ready() -> void:
	color = ProjectSettings.get_setting("game/player_color")[id - 1]
