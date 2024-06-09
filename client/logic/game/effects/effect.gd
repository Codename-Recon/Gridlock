extends Node2D
class_name Effect

@onready var player: AnimationPlayer = $AnimationPlayer


func _on_sprite_animation_2d_animation_looped() -> void:
	queue_free()
