class_name UnitStats
extends Node2D
signal round_over_changed

@export var health: int = 100:
	set(value):
		last_damage = health - value
		health = value
		if health > ProjectSettings.get_setting("global/unit/max_health"):
			health = ProjectSettings.get_setting("global/unit/max_health")
		_update_health_label()

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
				if ammo > _parent.values.ammo:
					ammo = _parent.values.ammo
				var ammo_threshold: int = ProjectSettings.get_setting(
					"global/unit/ammo_blink_threshold"
				)
				if ammo < (_parent.values.ammo * ammo_threshold):
					ammo_low = true
				else:
					ammo_low = false

@export var fuel: int = 0:
	set(value):
		# -1 means no fuel is needed
		if fuel > -1:
			fuel = value
			if is_inside_tree():
				if fuel > _parent.values.fuel:
					fuel = _parent.values.fuel
				var fuel_threshold: int = ProjectSettings.get_setting(
					"global/unit/fuel_blink_threshold"
				)
				if fuel < (_parent.values.fuel * fuel_threshold):
					fuel_low = true
				else:
					fuel_low = false

@export var last_damage: int = 0

@export var round_over: bool = false:
	set(value):
		if round_over != value:
			round_over = value
			round_over_changed.emit()

@export var is_hidden: bool = false

@onready var _health_label: Label = %Health as Label
@onready var _capture_icon: TextureRect = %CaptureIcon as TextureRect
@onready var _carrying_icon: TextureRect = %CarryingIcon as TextureRect
@onready var _animation_ammo: AnimationPlayer = %AnimationAmmo as AnimationPlayer
@onready var _animation_fuel: AnimationPlayer = %AnimationFuel as AnimationPlayer
@onready var _stars: UnitStatsStars = %Stars as UnitStatsStars
@onready var _parent: Unit = get_parent()


func get_last_damage_as_float() -> float:
	return last_damage / 10.0


func is_unit_damaged() -> bool:
	return health < ProjectSettings.get_setting("global/unit/max_health")


func can_be_refilled() -> bool:
	return fuel < _parent.values.fuel or ammo < _parent.values.ammo
	
func uses_fuel_on_turn() -> bool:
	return _parent.values.turn_fuel > 0 or _parent.values.hidden_turn_fuel > 0

func uses_fuel_on_turn() -> bool:
	return _parent.values.turn_fuel > 0 or _parent.values.hidden_turn_fuel>0

func can_destroy_on_empty_fuel() -> bool:
	# only units that consume fuel in idle can be destroyed if get run of petrol,
	# in the future, we can have extra properties for that if really needed
	return _parent.values.turn_fuel > 0

func _ready() -> void:
	ammo = _parent.values.ammo
	fuel = _parent.values.fuel
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
	_update_health_label()


func _update_health_label() -> void:
	var max_health: int = ProjectSettings.get_setting("global/unit/max_health")
	if health < max_health and health > 0:
		# round up value
		var round_value: int = ProjectSettings.get_setting("global/unit/health_rounding_value")
		var text_value: int = round((health + round_value) / 10.0) as int
		if _health_label:
			_health_label.text = str(text_value)
			_health_label.show()
	else:
		if _health_label:
			_health_label.hide()
