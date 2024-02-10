class_name GlobalSound
extends Node

signal settings_changed


func play(sound: String) -> void:
	(get_node(sound) as AudioStreamPlayer).play()
