class_name RoundLabel
extends Label

@export var player_name: String:
	set(value):
		player_name = value
		# text = "%s %s %s" % [tr("PLAYER"), str(value), tr("TURN")]
		text = tr("PLAYER_TURN", "Round announcement, showing which player's turn it is.").format({player_name= value})


func _ready() -> void:
	player_name = "1"
