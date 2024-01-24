extends Button
class_name GameButton

func _pressed() -> void:
	((Sound as GlobalSound).get_node("Click") as AudioStreamPlayer).play()
