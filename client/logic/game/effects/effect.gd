extends Node2D
class_name Effect

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var sprite_animation_2d: AnimatedSprite2D = $SpriteAnimation2D


func _on_sprite_animation_2d_animation_looped() -> void:
	queue_free()


func _on_animation_player_animation_started(anim_name: String) -> void:
	sprite_animation_2d.play()
