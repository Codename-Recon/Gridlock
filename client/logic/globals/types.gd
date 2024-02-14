@tool
class_name GlobalTypes
extends Node

@export var force_update: bool = false:
	set(value):
		force_update = false
		if Engine.is_editor_hint():
			_generate_types()

@export_category("Generated Data")
@export_group("Types")
@export var movement_types: Array
@export var unit_types: Array
@export var terrain_types: Array
@export var terrain_sprite_types: Array
@export var weapon_types: Array
@export var weather_types: Array
@export_group("Values")
@export var units: Dictionary
@export var terrains: Dictionary
# Structure: [String/terrain_type] [String/weather_type] [String/movement_type]
@export var movements: Dictionary
# Structure: [String/attacker/unit_type] [String/defender/unit_type]
@export var primary_damage: Dictionary
@export var secondary_damage: Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		_generate_types()


func _generate_types() -> void:
	var file_name: String
	var path: String = ProjectSettings.globalize_path("res://") + "../types/enum.json"
	var enum_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not enum_file:
		push_error("Can not open file: " + path)
		return
	var json: JSON = JSON.new()
	json.parse(enum_file.get_as_text())
	movement_types = json.data["definitions"]["movement_type"]["enum"]
	unit_types = json.data["definitions"]["unit"]["enum"]
	terrain_types = json.data["definitions"]["terrain"]["enum"]
	terrain_sprite_types = json.data["definitions"]["terrain_sprite"]["enum"]
	weapon_types = json.data["definitions"]["weapon"]["enum"]
	weather_types = json.data["definitions"]["weather"]["enum"]
	
	path = ProjectSettings.globalize_path("res://") + "../types/units/"
	units = _get_folder_values(path)
	
	path = ProjectSettings.globalize_path("res://") + "../types/terrain/"
	terrains = _get_folder_values(path)
	
	path = ProjectSettings.globalize_path("res://") + "../types/movement/chart.json"
	movements = _get_movement_values(path, movement_types, terrain_types, weather_types)
	
	path = ProjectSettings.globalize_path("res://") + "../types/damage/primary.json"
	primary_damage = _get_damage_values(path, unit_types)

	path = ProjectSettings.globalize_path("res://") + "../types/damage/secondary.json"
	secondary_damage = _get_damage_values(path, unit_types)
	
	_replace_movement_index_with_type()
	_replace_weapon_index_with_types()

func _get_folder_values(path: String) -> Dictionary:
	var dic: Dictionary = {}
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		push_error("Can not open directory: " + path)
		return {}
	for file_name: String in dir.get_files():
		var file: FileAccess = FileAccess.open(path + file_name, FileAccess.READ)
		if not file:
			push_error("Can not open file: " + path + file_name)
			return {}
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		dic[json.data["name"]] = json.data
	return dic


func _get_movement_values(path: String, movement_types: Array, terrain_types: Array, weather_types: Array) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Can not open file: " + path)
		return {}
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	var dic: Dictionary = {}
	var data: Array = json.data
	for t: int in data.size():
		var sub_data: Array = data[t]
		var terrain: Dictionary = {}
		dic[terrain_types[t]] = terrain
		for w: int in sub_data.size():
			var sub_sub_data: Array = sub_data[w]
			var weather: Dictionary = {}
			terrain[weather_types[w]] = weather
			for m: int in sub_sub_data.size():
				weather[movement_types[m]] = sub_sub_data[m]
	return dic


func _get_damage_values(path: String, unit_types: Array) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Can not open file: " + path)
		return {}
	var json: JSON = JSON.new()
	json.parse(file.get_as_text())
	var dic: Dictionary = {}
	var data: Array = json.data
	for a: int in data.size():
		var sub_data: Array = data[a]
		var attacker: Dictionary = {}
		dic[unit_types[a]] = attacker
		for d: int in sub_data.size():
			attacker[unit_types[d]] = sub_data[d]
	return dic


func _replace_movement_index_with_type() -> void:
	for unit: String in units:
		units[unit]["movement_type"] = movement_types[units[unit]["movement_type"]]

func _replace_weapon_index_with_types() -> void:
	for unit: String in units:
		var weapons: Array = []
		for index: int in units[unit]["weapons"]:
			if index >= 0:
				weapons.append(weapon_types[index])
		units[unit]["weapons"] = weapons
