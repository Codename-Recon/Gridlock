extends Node
class_name GlobalSound

signal settings_changed

func play(sound: String) -> void:
	(get_node(sound) as AudioStreamPlayer).play()
