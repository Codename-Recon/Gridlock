class_name TerrainStats
extends Node2D

@export var capture_health: int


func _ready() -> void:
	reset_capture_health()


func reset_capture_health() -> void:
	capture_health = 200
