class_name GlobalGlobal
extends Node

const CONFIG_FILE_PATH: String = "user://config.cfg"
const CONFIG_SECTION: String = "game"
const RENDERING_SECTION: String = "rendering"
const MAP_FOLDER_PATH: String = "res://assets/maps/maps/"
const MAP_CUSTOM_FOLDER_PATH: String = "user://maps/"
const SCENARIO_CUSTOM_FOLDER_PATH: String = "user://scenarios/"

var selected_map_json: String
var selected_scenario_json: String
var game_mode: GameConst.GameMode
var last_loaded_map: Map

var last_player_won_name: String = "X"
var last_player_won_color: Color = Color.GREEN

var game_scene: PackedScene = load("res://levels/game.tscn")
var menu_scene: PackedScene = load("res://levels/menu.tscn")
var gameover_scene: PackedScene = load("res://levels/game_over_screen.tscn")

var config: ConfigFile = ConfigFile.new()
var maps: Dictionary = {}


func save_config(key: String, value: Variant, section: String = CONFIG_SECTION) -> void:
	config.set_value(section, key, value)
	config.save(CONFIG_FILE_PATH)


func reload_maps() -> void:
	maps.clear()
	_load_maps(MAP_FOLDER_PATH)
	_load_maps(MAP_CUSTOM_FOLDER_PATH)


func _ready() -> void:
	config.load(CONFIG_FILE_PATH)
	_create_missing_folders()


func _create_missing_folders() -> void:
	if not DirAccess.dir_exists_absolute(MAP_CUSTOM_FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(MAP_CUSTOM_FOLDER_PATH)
	if not DirAccess.dir_exists_absolute(SCENARIO_CUSTOM_FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(SCENARIO_CUSTOM_FOLDER_PATH)


func _load_maps(dir_path: String) -> void:
	var folder: DirAccess = DirAccess.open(dir_path)
	for file_name: String in folder.get_files():
		if not file_name.ends_with(".glm"):
			continue
		var map_json: String = MapFile.load_from_file(
			"%s/%s" % [folder.get_current_dir(), file_name]
		)
		var map: Map = MapFile.deserialize(map_json)
		maps[map.map_name] = map_json
		map.queue_free()
