extends Decal

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	
func _on_visibility_changed() -> void:
	if visible:
		modulate.a = 0
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, ProjectSettings.get_setting("global/fast_animation_time") as float).set_ease(Tween.EASE_IN_OUT)
