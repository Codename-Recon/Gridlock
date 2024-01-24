extends Node2D
class_name TerrainStats

@export var capture_health: int

func _ready() -> void:
	reset_capture_health()

func reset_capture_health() -> void:
	var properties: TerrainProperty = (get_parent() as Terrain).properties
	capture_health = properties.capture_health
