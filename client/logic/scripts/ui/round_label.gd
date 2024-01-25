class_name RoundLabel
extends Label

@export var player_name: String:
	set(value):
		player_name = value
		text = "%s %s %s" % [tr("PLAYER"), str(value), tr("TURN")]


func _ready() -> void:
	player_name = "1"
