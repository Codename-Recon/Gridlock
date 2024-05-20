extends Decal


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		modulate.a = 0
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		var time: float = ProjectSettings.get_setting("global/decal_animation_time") as float
		tween.tween_property(self, "modulate:a", 1.0, time)
