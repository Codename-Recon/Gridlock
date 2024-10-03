@icon("res://assets/images/icons/nodes/person-outline.svg")
class_name Player
extends Node

enum Type {
	HUMAN,
	AI,
	NETWORK,
}

enum AiDifficulty {
	EASY,
	MEDIUM,
	HARD,
}

var id: int:
	set(value):
		color = ProjectSettings.get_setting("game/player_color")[value - 1]
		id = value

var money: int = 0
var team: int = 0
var type: Type = Type.HUMAN
var ai_difficulty: AiDifficulty = AiDifficulty.EASY
var color: Color


func _ready() -> void:
	color = ProjectSettings.get_setting("game/player_color")[id - 1]
