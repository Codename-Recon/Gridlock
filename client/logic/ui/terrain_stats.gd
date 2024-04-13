class_name TerrainStats
extends Node2D

@export var capture_health: int
@export var health: int
@export var ammo: int

@onready var _parent: Terrain = get_parent()

var _types: GlobalTypes = Types

func _ready() -> void:
	reset_capture_health()
	health = _types.terrains[_parent.id]["health"]
	ammo = _types.terrains[_parent.id]["ammo"]

func reset_capture_health() -> void:
	capture_health = 200
