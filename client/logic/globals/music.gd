extends Node

signal settings_changed
signal music_finished

const LOWEST_VOLUME: float = -50.0

var player: Array[AudioStreamPlayer]

var _tween1: Tween
var _tween2: Tween

func _ready() -> void:
	player = [$Player1, $Player2]
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	player[0].volume_db = volume
	player[1].volume_db = volume


func change_music(music: AudioStream) -> void:
	if _tween1 and _tween2:
		if _tween1.is_running():
			await _tween1.finished
		if _tween2.is_running():
			await _tween2.finished
	var front: AudioStreamPlayer = player.pop_front()
	player.append(front)
	player[0].stream = music
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	var time: float = ProjectSettings.get_setting("global/music_tween_time")
	player[0].volume_db = LOWEST_VOLUME
	player[0].play()
	_tween1 = create_tween()
	_tween1.tween_property(player[0], "volume_db", volume, time)
	_tween2 = create_tween()
	_tween2.tween_property(player[1], "volume_db", LOWEST_VOLUME, time)
	_tween2.tween_callback(player[1].stop)


func _on_music_settings_changed() -> void:
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	player[0].volume_db = volume
	player[1].volume_db = volume


func _on_player_1_finished() -> void:
	music_finished.emit()


func _on_player_2_finished() -> void:
	music_finished.emit()
