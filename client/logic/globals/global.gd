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
var loaded_scenario: Scenario

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


func save_current_scenario_progress() -> void:
	var stats: ScenarioProgress = generate_scenario_progress(loaded_map, loaded_scenario)
	save_scenario_progress(loaded_scenario.id, stats)


func save_scenario_progress(scenario_id: String, stats: ScenarioProgress) -> void:
	var dict: Dictionary = inst_to_dict(stats)
	for key: String in dict:
		if key == "@path" or key == "@subpath":
			continue
		progress.set_value(scenario_id, key, dict[key])
	progress.save_encrypted_pass(SCENARIO_PROGRESS_FILE, SCENARIO_PROGRESS_PASSWORD)


func has_scenario_progress(scenario_id: String) -> bool:
	return progress.has_section(scenario_id)


func load_scenario_progress(scenario_id: String) -> ScenarioProgress:
	var stats: ScenarioProgress = ScenarioProgress.new()
	var dict: Dictionary = inst_to_dict(stats)
	dict["@path"] = "res://logic/globals/global.gd"
	dict["@subpath"] = "ScenarioProgress"
	for key: String in dict:
		if key == "@path" or key == "@subpath":
			continue
		dict[key] = progress.get_value(scenario_id, key)
	stats = dict_to_inst(dict)
	return stats


## Calculates the scenario score based on rounds and kd value ratio.
func generate_scenario_progress(map: Map, scenario: Scenario) -> ScenarioProgress:
	var killed_value: int = scenario.stats.killed_value
	var lost_value: int = scenario.stats.lost_value
	var stats: ScenarioProgress = ScenarioProgress.new()
	if map.game_round < 0 or killed_value < 0 or lost_value < 0:
		printerr("Rounds, kill value or death value can't be smaller than zero.")
		return stats
	stats.round = map.game_round
		
	# Calculation kill death score with a ratio. It is possible to have a negative score.
	# This score is for fine-tuning the final score.
	if lost_value == 0:
		lost_value = 1 # to prevent division by zero
	var kd_value_ratio: float = float(killed_value) / float(lost_value)
	stats.kd_value_ratio = kd_value_ratio
	var kd_score_scale: int = ProjectSettings.get_setting("global/scenario/kd_score_scale")
	var kd_score_cap: int = ProjectSettings.get_setting("global/scenario/kd_score_cap")
	var kd_score: int = int(kd_value_ratio * kd_score_scale) - kd_score_scale
	if kd_score > kd_score_cap:
		kd_score = kd_score_cap
	
	# Calculating the round score based on a linear function
	var a_round: int = scenario.conditions.a_round
	var c_round: int = scenario.conditions.c_round
	var sloap: float = -2 / (3 * (c_round - a_round))
	var intercept: float = 1 + (2 * a_round) / (3 * (c_round - a_round))
	var round_score_factor: float = sloap * stats.round + intercept
	if round_score_factor < 0:
		round_score_factor = 0
	var round_score_scale: int = ProjectSettings.get_setting("global/scenario/round_score_scale")
	var round_score: int = int(round_score_factor * round_score_scale)
	
	stats.score = round_score + kd_score
	
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
		var scenario: Scenario = ScenarioFile.deserialize(scenario_json)
		container[scenario.id] = {"map": map_json, "scenario": scenario_json}


class ScenarioProgress extends NumberFix:
	var round: int
	var kd_value_ratio: int
	var score: int
