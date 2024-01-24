@tool
extends ProgressBar
class_name ProgressBarEnhanced

var super_fore_ground: StyleBoxTexture = preload("res://assets/resources/theme/progress_bar_enhanced_style_box.tres")

func _ready() -> void:
	pass

func _draw() -> void:
	if super_fore_ground and visible:
		var rect = Rect2(Vector2.ZERO, get_rect().size)
		super_fore_ground.draw(get_canvas_item(), rect)
