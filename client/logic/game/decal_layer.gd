class_name DecalLayer
extends Sprite2D

enum Type { MOVE, ATTACK, REFILL, ENTER, DEPLOY, JOIN }

@export var textures: Array[Texture]

var type: Type:
	set(value):
		type = value
		texture = textures[type]


func _ready() -> void:
	($AnimationPlayer as AnimationPlayer).play("init")
