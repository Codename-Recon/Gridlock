@icon("res://assets/images/icons/person-outline.svg")
@tool
class_name Player
extends Node

@export var player_number: int:
	set(value):
		color = ProjectSettings.get_setting("global/player_colors")[value - 1]
		player_number = value

@export var input_type: GameConst.InputType = GameConst.InputType.HUMAN

@export var money: int = 0:
	set(value):
		money = value

@export var ai_difficulty: GameConst.AiDifficulty = GameConst.AiDifficulty.EASY

var color: Color


func _ready() -> void:
	color = ProjectSettings.get_setting("global/player_colors")[player_number - 1]
