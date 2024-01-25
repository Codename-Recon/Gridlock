extends SubViewport


func _ready() -> void:
	_set_graphics()
	(Graphic as GlobalGraphics).settings_changed.connect(_set_graphics)


func _set_graphics() -> void:
	(Graphic as GlobalGraphics).set_anti_aliasing_quality(self)
