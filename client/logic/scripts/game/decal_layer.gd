extends Sprite2D
class_name DecalLayer
@export var textures: Array[Texture]

enum Type{
	MOVE,
	ATTACK,
	REFILL,
	ENTER,
	DEPLOY,
	JOIN
}

var type: Type:
	set(value):
		type = value
		texture = textures[type]

func _ready() -> void:
	($AnimationPlayer as AnimationPlayer).play("init")
