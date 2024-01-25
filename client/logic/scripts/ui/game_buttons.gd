class_name GameButton
extends Button


func _pressed() -> void:
	((Sound as GlobalSound).get_node("Click") as AudioStreamPlayer).play()
