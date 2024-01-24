extends Node
class_name GlobalGraphics

signal settings_changed

enum AntiAliasingQuality{
	LOW,
	MEDIUM,
	HIGH,
	ULTRA
}

enum ShadowQuality{
	LOW,
	MEDIUM,
	HIGH,
	ULTRA
}

var MSAAQualityMap: Dictionary = {AntiAliasingQuality.LOW: 0, AntiAliasingQuality.MEDIUM: 1, AntiAliasingQuality.HIGH: 2, AntiAliasingQuality.ULTRA: 3}
var ShadowQualityMap: Dictionary = {ShadowQuality.LOW: 512, ShadowQuality.MEDIUM: 1024, ShadowQuality.HIGH: 2048, ShadowQuality.ULTRA: 4096}

# function for viewports to set their settings acording to game settings
func set_anti_aliasing_quality(viewport: SubViewport) -> void:
	var anti_aliasing: int = ProjectSettings.get_setting("game/graphics_anti_aliasing")
	viewport.msaa_3d = MSAAQualityMap[anti_aliasing]
	if anti_aliasing > AntiAliasingQuality.HIGH:
		# TODO: TAA has still some weird effects. Mabye it gets better with never godot versions.
		viewport.use_taa = false
		#viewport.use_taa = true
	else:
		viewport.use_taa = false

func _ready() -> void:
	_set_graphics()
	
func _set_graphics() -> void:
	# TODO: This has no effect atm. It gets set, but there is no graphicall difference. Maybe there is an additional process needed which applies those settings.
	var shadow_quality: int = ProjectSettings.get_setting("game/graphics_shadow_quality")
	ProjectSettings.set_setting("rendering/shadows/directional_shadow/size", ShadowQualityMap[shadow_quality])
	ProjectSettings.set_setting("rendering/shadows/directional_shadow/size", ShadowQualityMap[shadow_quality])	
