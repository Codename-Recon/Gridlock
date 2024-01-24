@icon("res://assets/images/icons/settings-2-outline.svg")
extends Resource
class_name UnitProperty

enum MovementType{
	NONE,
	THREADS,
	TIRES,
	AIR,
	SEA,
	LANDER,
	FOOT,
	BOOTS,
	PIPE
}

@export var name: String = "Unit"
@export var health: int = 100
@export var movement_points: int
@export var ammo: int = -1
@export var fuel: int = -1
@export var daily_fuel_decay: int = 0
@export var vision: int = 2
@export var min_range: int = 1
@export var max_range: int = 1
@export var movement_type: MovementType
@export var cost: int = 0
@export var can_capture: bool = false
@export var can_move_and_attack: bool = true
@export var can_refill: bool = false
@export var weapons: Array
@export var damage_table: Dictionary
@export var carrying_types: Array[MovementType]
@export var carrying_size: int = 0
@export_multiline var description: String
