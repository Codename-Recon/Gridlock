extends DirectionalLight3D


func _ready() -> void:
	var selected: GlobalGraphics.ShadowQuality = ProjectSettings.get_setting(
		"game/graphics_shadow_quality"
	)
	if selected == Graphic.ShadowQuality.LOW:
		shadow_enabled = false
	else:
		shadow_enabled = true
