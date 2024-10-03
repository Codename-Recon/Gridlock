class_name ScenarioFile
extends Node

const SCENARIO_VERSION: String = "1.0.0"

static var _global: GlobalGlobal = Global

static func save_to_file(json_map: String, json_scenario: String, file_name: String) -> void:
	var packer: ZIPPacker = ZIPPacker.new()
	packer.open("%s/%s.gls" % [_global.SCENARIO_CUSTOM_FOLDER_PATH, file_name])
	packer.start_file("map.json")
	packer.write_file(json_map.to_utf8_buffer())
	packer.close_file()
	packer.start_file("scenario.json")
	packer.write_file(json_scenario.to_utf8_buffer())
	packer.close_file()
	packer.close()


static func load_from_file(file_path: String) -> Array[String]:
	var reader: ZIPReader = ZIPReader.new()
	reader.open(file_path)
	var map_data: PackedByteArray = reader.read_file("map.json")
	var scenario_data: PackedByteArray = reader.read_file("scenario.json")
	reader.close()
	return [map_data.get_string_from_utf8(), scenario_data.get_string_from_utf8()]


static func serialize(scenario: Scenario) -> String:
	var scenario_values: ScenarioValues = ScenarioValues.new()
	scenario_values.version = SCENARIO_VERSION
	scenario_values.order = scenario.order
	
	var stat_values: StatValues = StatValues.new()
	stat_values.killed_units = scenario.stats.killed_units
	stat_values.killed_value = scenario.stats.killed_value
	stat_values.lost_units = scenario.stats.lost_units
	stat_values.lost_value = scenario.stats.lost_value
	stat_values.captured = scenario.stats.captured
	scenario_values.stats = inst_to_dict(stat_values)
	
	var condition_value: ConditionValues = ConditionValues.new()
	condition_value.max_round = scenario.conditions.max_round
	
	var s_rank_stats: StatValues = StatValues.new()
	s_rank_stats.killed_units = scenario.conditions.s_rank_stats.killed_units
	s_rank_stats.killed_value = scenario.conditions.s_rank_stats.killed_value
	s_rank_stats.lost_units = scenario.conditions.s_rank_stats.lost_units
	s_rank_stats.lost_value = scenario.conditions.s_rank_stats.lost_value
	s_rank_stats.captured = scenario.conditions.s_rank_stats.captured
	condition_value.s_rank_stats = inst_to_dict(s_rank_stats)
	
	scenario_values.conditions = inst_to_dict(condition_value)
	
	return JSON.stringify(inst_to_dict(scenario_values), "\t")


static func deserialize(json_scenario: String) -> Scenario:
	var scenario: Scenario = Scenario.new()
	
	var dic: Dictionary = JSON.parse_string(json_scenario)
	dic["@path"] = "res://logic/game/maps/scenario_file.gd"
	dic["@subpath"] = "ScenarioValues"
	var scenario_values: ScenarioValues = dict_to_inst(dic)
	
	scenario.order = scenario_values.order
	
	scenario_values.stats["@path"] = "res://logic/game/maps/scenario_file.gd"
	scenario_values.stats["@subpath"] = "StatValues"
	var stat_values: StatValues = dict_to_inst(scenario_values.stats)
	scenario.stats = Scenario.Stats.new()
	scenario.stats.killed_units = stat_values.killed_units
	scenario.stats.killed_value = stat_values.killed_value
	scenario.stats.lost_units = stat_values.lost_units
	scenario.stats.lost_value = stat_values.lost_value
	scenario.stats.captured = stat_values.captured
	
	scenario_values.conditions["@path"] = "res://logic/game/maps/scenario_file.gd"
	scenario_values.conditions["@subpath"] = "ConditionValues"
	var condition_values: ConditionValues = dict_to_inst(scenario_values.conditions)
	scenario.conditions = Scenario.Conditions.new()
	scenario.conditions.max_round = condition_values.max_round
	
	condition_values.s_rank_stats["@path"] = "res://logic/game/maps/scenario_file.gd"
	condition_values.s_rank_stats["@subpath"] = "StatValues"
	var s_rank_stats: StatValues = dict_to_inst(condition_values.s_rank_stats)
	scenario.conditions.s_rank_stats = Scenario.Stats.new()
	scenario.conditions.s_rank_stats.killed_units = s_rank_stats.killed_units
	scenario.conditions.s_rank_stats.killed_value = s_rank_stats.killed_value
	scenario.conditions.s_rank_stats.lost_units = s_rank_stats.lost_units
	scenario.conditions.s_rank_stats.lost_value = s_rank_stats.lost_value
	scenario.conditions.s_rank_stats.captured = s_rank_stats.captured
	
	return scenario


class ScenarioValues extends NumberFix:
	var version: String
	var order: int
	var stats: Dictionary
	var conditions: Dictionary
	var events: Dictionary


class StatValues extends NumberFix:
	var killed_units: int
	var killed_value: int
	var lost_units: int
	var lost_value: int
	var captured: int


class ConditionValues extends NumberFix:
	var max_round: int
	var s_rank_stats: Dictionary
