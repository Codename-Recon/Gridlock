extends AudioStreamPlayer2D

var base_volume: float = volume_db


func _ready() -> void:
	Sound.settings_changed.connect(_on_settings_changed)
	_on_settings_changed(ProjectSettings.get_setting("game/sound_volume") as float)


func _on_settings_changed(value: float) -> void:
	volume_db = base_volume + value
