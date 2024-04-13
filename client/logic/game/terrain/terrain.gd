@icon("res://assets/images/icons/nodes/flag-outline.svg")
@tool
class_name Terrain
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var shader_modulate: bool = false:
	set(value):
		if value && has_node("./Sprite2D"):
			shader_modulate = value
			if sprite && sprite.material:
				(sprite.material as ShaderMaterial).set_shader_parameter("shifting", value)

@export_color_no_alpha var color: Color:
	set(value):
		if value:
			var color_a: Color = Color(value, 1)
			if modulate && has_node("./Sprite2D"):
				if is_inside_tree():
					var color_old: Color
					if color:
						color_old = Color(color, 1)
					else:
						color_old = Color.WHITE
						color_old.a = 0
					var tween: Tween = get_tree().create_tween()
					tween.tween_method(
						_set_color,
						color_old,
						color_a,
						ProjectSettings.get_setting("global/tint_time") as float
					)
				else:
					_set_color(color_a)
			color = value

@export var player_owned: Player:
	set(value):
		if _types.terrains[id]["can_capture"]:
			player_owned = value
			_update_color()

@export var id: String
@export var tile_id: String
@export var shop_units: Array[PackedScene]

## layer variable for color layer, handled that only one layer can be set (new layer overwrites old one)
@export var layer: Sprite2D:
	set(value):
		if value:
			if layer != null and layer in get_children():
				layer.queue_free()
				remove_child(layer)
			layer = value
			if value:
				add_child(value)
				value.global_rotation = 0

var _shader_resource: Shader = preload("res://logic/shaders/color_shift.tres")
var _types: GlobalTypes = Types

@onready var map: Map = get_parent()
@onready var stats: TerrainStats = $TerrainStats


func get_move_on_global_position() -> Vector2:
	return global_position


func has_unit() -> bool:
	for i: Node2D in get_children():
		# using workaround for checking if class is a unit, since "is" is causing cyclic reference
		if i.has_method("get_possible_terrains_to_move"):
			return true
	return false


func get_unit() -> Unit:
	for i: Node2D in get_children():
		# using workaround for checking if class is a unit, since "is" is causing cyclic reference
		if i.has_method("get_possible_terrains_to_move"):
			return i as Unit
	return null


## captures terrain. gives true back on success.
func capture(capture_force: int, player_of_unit: Player) -> bool:
	stats.capture_health -= capture_force
	if stats.capture_health <= 0:
		stats.reset_capture_health()
		player_owned = player_of_unit
		return true
	else:
		return false


func uncapture() -> void:
	stats.reset_capture_health()


func get_up() -> Terrain:
	var pos: Vector2i = (global_position + Vector2.UP * ProjectSettings.get_setting("global/grid_size").y)
	return map.get_terrain_by_position(pos)


func get_down() -> Terrain:
	var pos: Vector2i = (global_position + Vector2.DOWN * ProjectSettings.get_setting("global/grid_size").y)
	return map.get_terrain_by_position(pos)


func get_left() -> Terrain:
	var pos: Vector2i = (global_position + Vector2.LEFT * ProjectSettings.get_setting("global/grid_size").y)
	return map.get_terrain_by_position(pos)


func get_right() -> Terrain:
	var pos: Vector2i = (global_position + Vector2.RIGHT * ProjectSettings.get_setting("global/grid_size").y)
	return map.get_terrain_by_position(pos)


func is_neighbor(terrain: Terrain) -> bool:
	return (
		terrain.get_up() == self
		or terrain.get_down() == self
		or terrain.get_left() == self
		or terrain.get_right() == self
	)


func _ready() -> void:
	if not sprite.material:
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = _shader_resource
		sprite.material = material
	# Add shop units
	shop_units.clear()
	for unit_id: String in _types.terrains[id]["shop_units"]:
		shop_units.append(Map.predefined_units_packed_scenes[unit_id])
	shop_units.sort_custom(_sort_by_unit_price)
	_update_color()


func _sort_by_unit_price(a: PackedScene, b: PackedScene) -> bool:
	var a_scene: Unit = a.instantiate()
	var b_scene: Unit = b.instantiate()
	return _types.units[a_scene.id]["cost"] < _types.units[b_scene.id]["cost"]
	

func _set_color(set_color: Color) -> void:
	var _sprite: Sprite2D = $Sprite2D as Sprite2D
	(_sprite.material as ShaderMaterial).set_shader_parameter("new_color", set_color)


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		add_to_group("terrain")


func _exit_tree() -> void:
	remove_from_group("terrain")


func _update_color() -> void:
	if _types.terrains[id]["can_capture"]:
		if player_owned:
			shader_modulate = true
			color = player_owned.color
		else:
			shader_modulate = true
			var neutral_color: Color = ProjectSettings.get_setting("game/neutral_color")
			color = neutral_color
