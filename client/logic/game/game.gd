extends Control

signal map_loaded

@export var musics: Array[AudioStream]

@onready var map_slot: Node = %MapSlot
@onready var game_input: GameInput = %GameInput

var _last_music: AudioStream
var _global: GlobalGlobal = Global
var _multiplayer: GlobalMultiplayer = Multiplayer


func end_game() -> void:
	map_slot.remove_child(map_slot.get_child(0)) # removing map from tree, so it doesn't get freed when changing scene
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
				player.type = Player.Type.AI
			var first_player: Player = map.players.get_children()[0]
			first_player.type = Player.Type.HUMAN
		GameConst.GameMode.HOTSEAT:
			for player: Player in map.players.get_children():
				player.type = Player.Type.HUMAN
		GameConst.GameMode.NETWORK:
			for player: Player in map.players.get_children():
				player.type = Player.Type.NETWORK
		GameConst.GameMode.BOOTCAMP:
			_global.loaded_scenario = ScenarioFile.deserialize(_global.selected_scenario_json)
		GameConst.GameMode.SCENARIO:
			_global.loaded_scenario = ScenarioFile.deserialize(_global.selected_scenario_json)
		GameConst.GameMode.CAMPAIGN:
			_global.loaded_scenario = ScenarioFile.deserialize(_global.selected_scenario_json)
	game_input.global_position = map.map_center
	_global.loaded_map = map
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
