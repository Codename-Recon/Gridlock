class_name GlobalSound
extends Node


func play(sound: String) -> void:
	(get_node(sound) as AudioStreamPlayer).play()


func _ready() -> void:
	# Set Sound volume with settings value
	var value: float = ProjectSettings.get_setting("game/sound_volume")
	var idx: int = AudioServer.get_bus_index("Sound")
	AudioServer.set_bus_volume_db(idx, value)
