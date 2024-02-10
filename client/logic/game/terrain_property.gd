@icon("res://assets/images/icons/settings-2-outline.svg")
@tool
class_name TerrainProperty
extends Resource

@export var name: String = "Terrain"
@export var movement_costs: Dictionary = {}
@export var defence_level: int = 0
@export var is_capturable: bool = false
@export var capture_health: int = 200
@export var round_funding: int = 0
@export var can_repair: bool = false
@export var can_buy: bool = false
@export var shop_units: Array[PackedScene]
@export_multiline var description: String

@export var generate_movement_costs: bool:
	set(value):
		if value:
			movement_costs = {}
			for i: String in UnitProperty.MovementType.keys():
				movement_costs[i] = 0


func get_movement_cost(type: UnitProperty.MovementType) -> int:
	return movement_costs[UnitProperty.MovementType.keys()[type]]
