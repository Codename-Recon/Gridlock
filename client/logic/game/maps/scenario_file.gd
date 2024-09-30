class_name ScenarioFile
extends Node

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
