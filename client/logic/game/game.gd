extends Control

signal map_loaded

@export var musics: Array[AudioStream]

@onready var map_slot: Node = %MapSlot
@onready var game_input: GameInput = %GameInput

var _last_music: AudioStream
var _global: GlobalGlobal = Global
var _multiplayer: GlobalMultiplayer = Multiplayer

func end_game() -> void:
	get_tree().change_scene_to_packed(_global.gameover_scene)
	if _multiplayer.client_role != _multiplayer.ClientRole.NONE:
		_multiplayer.nakama_disconnect_from_match()

func _ready() -> void:
	Music.music_finished.connect(_on_music_finished)
	_set_music()
	var map: Map = MapFile.deserialize(_global.selected_map_json)
	map_slot.add_child(map)
	map.name = "Map" # Renaming the map from generic name, so node path keeps consistent over network
	match _global.game_mode:
		GameConst.GameMode.SINGLE:
			for player: Player in map.players.get_children():
				player.input_type = GameConst.InputType.AI
			var first_player: Player = map.players.get_children()[0]
			first_player.input_type = GameConst.InputType.HUMAN
		GameConst.GameMode.HOTSEAT:
			for player: Player in map.players.get_children():
				player.input_type = GameConst.InputType.HUMAN
		GameConst.GameMode.NETWORK:
			for player: Player in map.players.get_children():
				player.input_type = GameConst.InputType.NETWORK
	game_input.global_position = map.map_center
	map_loaded.emit()

func _on_music_finished() -> void:
	_set_music()
	
func _set_music() -> void:
	var new_music: AudioStream = musics.pick_random()
	if musics.size() > 1:
		while _last_music == new_music:
			new_music = musics.pick_random()
	Music.change_music(new_music)
	_last_music = new_music
