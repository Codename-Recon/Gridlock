@tool
class_name MoveArrow
extends Path2D

@export_category("Textures")
@export var up_arrow: Texture
@export var vertical_line: Texture
@export var up_corner: Texture


func _ready() -> void:
	pass


func _on_draw() -> void:
	create_arrow()


func create_arrow() -> void:
	get_children().map(func(n: Node) -> void: n.queue_free())
	var points: PackedVector2Array = curve.get_baked_points()
	var direction: Vector2 = Vector2.ZERO
	var old_direction: Vector2
	for i: int in curve.point_count - 1:
		old_direction = direction
		direction = curve.get_point_position(i + 1) - curve.get_point_position(i)
		var sprite: Sprite2D = Sprite2D.new()
		if old_direction == Vector2.ZERO or abs(old_direction.angle_to(direction)) < 0.1:
			sprite.texture = vertical_line
		else:
			sprite.texture = up_corner
			if old_direction.angle_to(direction) < 0:
				sprite.scale.x *= -1
		sprite.rotation = direction.angle() + PI / 2
		sprite.global_position = curve.get_point_position(i)
		add_child(sprite)
	# add arrow head
	if curve.point_count > 1:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = up_arrow
		sprite.rotation = direction.angle() + PI / 2
		sprite.global_position = curve.get_point_position(curve.point_count - 1)
		add_child(sprite)
