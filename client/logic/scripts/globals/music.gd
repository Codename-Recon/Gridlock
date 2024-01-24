extends Node

signal settings_changed
signal music_finished

const lowest_volume: float = -50.0

var player: Array[AudioStreamPlayer]

func _ready() -> void:
	player = [$Player1, $Player2]
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	player[0].volume_db = volume
	player[1].volume_db = volume

func change_music(music: AudioStream) -> void:
	var front: AudioStreamPlayer = player.pop_front()
	player.append(front)
	player[0].stream = music
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	var time: float = ProjectSettings.get_setting("global/music_tween_time")
	player[0].volume_db = lowest_volume
	player[0].play()
	var tween1: Tween = create_tween()
	tween1.tween_property(player[0], "volume_db", volume, time)
	var tween2: Tween = create_tween()
	tween2.tween_property(player[1], "volume_db", lowest_volume, time)
	tween2.tween_callback(player[1].stop)


func _on_music_settings_changed() -> void:
	var volume: float = ProjectSettings.get_setting("game/music_volume")
	player[0].volume_db = volume
	player[1].volume_db = volume


func _on_player_1_finished() -> void:
	music_finished.emit()

func _on_player_2_finished() -> void:
	music_finished.emit()
