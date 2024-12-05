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


func is_enemy(player: Player) -> bool:
	if player == self:
		return false
	if player.team == 0:
		return true
	if player.team != team:
		return true
	return false


func _ready() -> void:
	color = ProjectSettings.get_setting("game/player_color")[id - 1]
