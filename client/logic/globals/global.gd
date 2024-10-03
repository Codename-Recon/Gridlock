class_name GlobalGlobal
extends Node

const CONFIG_FILE_PATH: String = "user://config.cfg"
const CONFIG_SECTION: String = "game"
const RENDERING_SECTION: String = "rendering"
const MAP_FOLDER_PATH: String = "res://assets/maps/maps/"
const MAP_CUSTOM_FOLDER_PATH: String = "user://maps/"
const BOOTCAMP_FOLDER_PATH: String = "res://assets/maps/bootcamp/"
const SCENARIO_FOLDER_PATH: String = "res://assets/maps/scenarios/"
const SCENARIO_CUSTOM_FOLDER_PATH: String = "user://scenarios/"
const SCENARIO_PROGRESS_PASSWORD: String = "Cheating is bad"
const SCENARIO_PROGRESS_FILE: String = "user://progress.dat"

var selected_map_json: String
var selected_scenario_json: String
var game_mode: GameConst.GameMode
var loaded_map: Map

var last_player_won_name: String = "X"
var last_player_won_color: Color = Color.GREEN

var game_scene: PackedScene = load("res://levels/game.tscn")
var menu_scene: PackedScene = load("res://levels/menu.tscn")
var gameover_scene: PackedScene = load("res://levels/game_over_screen.tscn")

var config: ConfigFile = ConfigFile.new()
var progress: ConfigFile = ConfigFile.new()
var maps: Dictionary = {}
var bootcamps: Dictionary = {}
var scenarios: Dictionary = {}


func save_config(key: String, value: Variant, section: String = CONFIG_SECTION) -> void:
	config.set_value(section, key, value)
	config.save(CONFIG_FILE_PATH)


func reload_maps() -> void:
	maps.clear()
	bootcamps.clear()
	scenarios.clear()
	_load_maps(MAP_FOLDER_PATH)
	_load_maps(MAP_CUSTOM_FOLDER_PATH)
	_load_scenarios(BOOTCAMP_FOLDER_PATH, bootcamps)
	_load_scenarios(SCENARIO_FOLDER_PATH, scenarios)
	_load_scenarios(SCENARIO_CUSTOM_FOLDER_PATH, scenarios)


func generate_scenario_id(map_json: String, scenario_json: String) -> String:
	var md5: String = (map_json + scenario_json).md5_text()
	return md5


func save_scenario_progress(scenatio_id: String, stats: Scenario.Stats) -> void:
	var dict: Dictionary = inst_to_dict(stats)
	for key: String in dict:
		if key == "@path" or key == "@subpath":
			continue
		progress.set_value(scenatio_id, key, dict[key])
	progress.save_encrypted_pass(SCENARIO_PROGRESS_FILE, SCENARIO_PROGRESS_PASSWORD)


func load_scenario_progress(scenatio_id: String) -> Scenario.Stats:
	var stats: Scenario.Stats = Scenario.Stats.new()
	var dict: Dictionary = inst_to_dict(stats)
	dict["@path"] = "res://logic/game/maps/scenario.gd"
	dict["@subpath"] = "Stats"
	for key: String in dict:
		if key == "@path" or key == "@subpath":
			continue
		dict[key] = progress.get_value(scenatio_id, key)
	stats = dict_to_inst(dict)
	return stats


func _ready() -> void:
	config.load(CONFIG_FILE_PATH)
	progress.load_encrypted_pass(SCENARIO_PROGRESS_FILE, SCENARIO_PROGRESS_PASSWORD)
	_create_missing_folders()


func _create_missing_folders() -> void:
	if not DirAccess.dir_exists_absolute(MAP_CUSTOM_FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(MAP_CUSTOM_FOLDER_PATH)
	if not DirAccess.dir_exists_absolute(SCENARIO_CUSTOM_FOLDER_PATH):
		DirAccess.make_dir_recursive_absolute(SCENARIO_CUSTOM_FOLDER_PATH)


func _load_maps(dir_path: String) -> void:
	var folder: DirAccess = DirAccess.open(dir_path)
	if not folder:
		print_debug("Can't access folder %s" % dir_path)
		return
	for file_name: String in folder.get_files():
		if not file_name.ends_with(".glm"):
			continue
		var map_json: String = MapFile.load_from_file(
			"%s/%s" % [folder.get_current_dir(), file_name]
		)
		var map: Map = MapFile.deserialize(map_json)
		maps[map.map_name] = map_json
		map.queue_free()


func _load_scenarios(dir_path: String, container: Dictionary) -> void:
	var folder: DirAccess = DirAccess.open(dir_path)
	if not folder:
		print_debug("Can't access folder %s" % dir_path)
		return
	for file_name: String in folder.get_files():
		if not file_name.ends_with(".gls"):
			continue
		var data: Array[String] = ScenarioFile.load_from_file(
			"%s/%s" % [folder.get_current_dir(), file_name]
		)
		var map_json: String = data[0]
		var scenario_json: String = data[1]
		var map: Map = MapFile.deserialize(map_json)
		container[map.map_name] = {"map": map_json, "scenario": scenario_json}
		map.queue_free()
