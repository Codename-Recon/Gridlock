extends GameButton

@export var scene_to_go : PackedScene

func _pressed() -> void:
	super._pressed()
	get_tree().change_scene_to_packed(scene_to_go)
