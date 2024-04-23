class_name UnitStats
extends Node2D
signal round_over_changed

@export var health: int = 100:
	set(value):
		if is_inside_tree():
			var rounding_value: int = ProjectSettings.get_setting(
				"global/unit_health_rounding_value"
			)
			# smaller eg. 5 (4, 3 aso.) will be rounded down to 0. also negative numbers will be 0
			if value < rounding_value:
				value = 0
			# substracting round value so it doesn't show 97 value as 10 health
			if value < ProjectSettings.get_setting("global/unit_max_health") - rounding_value:
				var text_value: int = round(value / 10.0) as int
				_health_label.text = str(text_value)
				_health_label.show()
			else:
				value = ProjectSettings.get_setting("global/unit_max_health")
				_health_label.hide()
			last_damage = health - value
			health = value

@export var capturing: bool = false:
	set(value):
		if is_inside_tree():
			capturing = value
			_capture_icon.visible = value

@export var map_hidden: bool = false

@export var carrying: bool = false:
	set(value):
		if is_inside_tree():
			carrying = value
			_carrying_icon.visible = value

@export var ammo_low: bool = false:
	set(value):
		if is_inside_tree():
			ammo_low = value
			if value:
				_animation_ammo.play("AmmoBlink")
				_animation_fuel.seek(0)  # reset other animation for synchronous blinking
			else:
				_animation_ammo.play("RESET")

@export var fuel_low: bool = false:
	set(value):
		if is_inside_tree():
			fuel_low = value
			if value:
				_animation_fuel.play("FuelBlink")
				_animation_ammo.seek(0)  # reset other animation for synchronous blinking
			else:
				_animation_fuel.play("RESET")

@export var star_number: int = 0:
	set(value):
		if is_inside_tree():
			_stars.star_number = value
			star_number = value

@export var ammo: int = 0:
	set(value):
		# -1 means no weapon with extra ammo
		if ammo > -1:
			ammo = value
			if is_inside_tree():
				var unit: Unit = get_parent() as Unit
				if ammo > _types.units[unit.id]["ammo"]:
					ammo = _types.units[unit.id]["ammo"]
				var ammo_threshold: int = ProjectSettings.get_setting(
					"global/unit_ammo_blink_threshold"
				)
				if ammo < (_types.units[unit.id]["ammo"] * ammo_threshold):
					ammo_low = true
				else:
					ammo_low = false

@export var fuel: int = 0:
	set(value):
		# -1 means no fuel is needed
		if fuel > -1:
			fuel = value
			if is_inside_tree():
				var unit: Unit = get_parent() as Unit
				if fuel > _types.units[unit.id]["fuel"]:
					fuel = _types.units[unit.id]["fuel"]
				var fuel_threshold: int = ProjectSettings.get_setting(
					"global/unit_fuel_blink_threshold"
				)
				if fuel < (_types.units[unit.id]["fuel"] * fuel_threshold):
					fuel_low = true
				else:
					fuel_low = false

@export var last_damage: int = 0

@export var round_over: bool = false:
	set(value):
		if round_over != value:
			round_over = value
			round_over_changed.emit()

@onready var _health_label: Label = %Health as Label
@onready var _capture_icon: TextureRect = %CaptureIcon as TextureRect
@onready var _carrying_icon: TextureRect = %CarryingIcon as TextureRect
@onready var _animation_ammo: AnimationPlayer = %AnimationAmmo as AnimationPlayer
@onready var _animation_fuel: AnimationPlayer = %AnimationFuel as AnimationPlayer
@onready var _stars: UnitStatsStars = %Stars as UnitStatsStars

var _types: GlobalTypes = Types


func _ready() -> void:
	var unit: Unit = get_parent() as Unit
	ammo = _types.units[unit.id]["ammo"]
	fuel = _types.units[unit.id]["fuel"]
	if ammo_low:
		_animation_ammo.play("AmmoBlink")
	else:
		_animation_ammo.play("RESET")
	if fuel_low:
		_animation_fuel.play("FuelBlink")
	else:
		_animation_fuel.play("RESET")
	_capture_icon.visible = capturing
	_carrying_icon.visible = carrying


func get_last_damage_as_float() -> float:
	return last_damage / 10.0


func is_unit_damaged() -> bool:
	return health < ProjectSettings.get_setting("global/unit_max_health")


func can_be_refilled() -> bool:
	var unit: Unit = get_parent() as Unit
	return fuel < _types.units[unit.id]["fuel"] or ammo < _types.units[unit.id]["ammo"]
