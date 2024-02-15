class_name TerrainStats
extends Node2D

@export var capture_health: int

var _types: GlobalTypes = Types


func _ready() -> void:
	reset_capture_health()


func reset_capture_health() -> void:
	capture_health = 200
