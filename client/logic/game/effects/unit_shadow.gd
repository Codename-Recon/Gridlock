@icon("res://assets/images/icons/nodes/download-outline.svg")
@tool
class_name UnitShadow
extends Sprite2D

@export_range(0, 1, 0.01) var shadow_alpha: float = 0.5:
	set(value):
		shadow_alpha = value
		_update_shadow_settings()


@export_range(0, 1, 0.01) var shadow_scale: float = 0.5:
	set(value):
		shadow_scale = value
		_update_shadow_settings()


@export_range(0.1, 1, 0.01) var shadow_squish: float = 1.0:
	set(value):
		shadow_squish = value
		_update_shadow_settings()

var _parent: AnimatedSprite2D


func _enter_tree() -> void:
	_update_shadow_settings()
	if get_parent() is AnimatedSprite2D:
		_parent = get_parent()
		_parent.frame_changed.connect(_on_frame_changed)
		_parent.draw.connect(_on_draw)
		texture = _parent.sprite_frames.get_frame_texture(_parent.animation, _parent.frame)

func _exit_tree() -> void:
	if _parent:
		_parent.frame_changed.disconnect(_on_frame_changed)
		_parent.draw.disconnect(_on_draw)
		texture = null
		_parent = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_parent() is not AnimatedSprite2D:
		warnings.append("UnitShadow has to be placed as a child of an AnimatedSprite2D")
	return warnings


func _on_frame_changed() -> void:
	texture = _parent.sprite_frames.get_frame_texture(_parent.animation, _parent.frame)


func _on_draw() -> void:
	flip_h = _parent.flip_h


func _update_shadow_settings() -> void:
	modulate = Color.BLACK
	modulate.a = shadow_alpha
	scale.x = shadow_scale
	scale.y = shadow_scale * shadow_squish
	z_index = -1
