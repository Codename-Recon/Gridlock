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

var shop_units: Array[PackedScene]

var values: Values:
	get:
		if not values:
			# Load values from types
			var values_dic: Dictionary = _types.terrains[id]
			values_dic["@path"] = "res://logic/game/terrain/terrain.gd"
			values_dic["@subpath"] = "Values"
			values = dict_to_inst(values_dic)
			values.fix()
		return values

var _shader_resource: Shader = preload("res://logic/shaders/color_shift.tres")
var _types: GlobalTypes = Types

@onready var stats: TerrainStats = $TerrainStats


static func _lambda_calculate_distance(start: Terrain, end: Terrain) -> int:
	var distance: Vector2i = end.global_position - start.global_position
	distance /= ProjectSettings.get_setting("global/grid_size")
	var move_value: int = round(abs(distance.x) + abs(distance.y))
	return move_value


static func filter_terrains(
	terrains: Array[Terrain], unit: Unit, filter_blocking: bool = true, filter_distance: bool = true
) -> Array[Terrain]:

	if filter_distance:
		# Removing terrains which are too far
		terrains = terrains.filter(
			func(a: Terrain) -> bool: return (
				_lambda_calculate_distance(unit.get_terrain(), a) <= unit.possible_movement_steps
			)
		)
	if filter_blocking:
		# Removing terrains which are blocked by units TODO: Team units do not block
		terrains = terrains.filter(
			func(a: Terrain) -> bool: return (
				not a.has_unit() or a.get_unit().player_owned == unit.player_owned
			)
		)
		# Removing terrains which are blocked by blocking terrains
		terrains = terrains.filter(
			func(a: Terrain) -> bool: return a.get_movement_cost(unit, GameConst.Weather.CLEAR) >= 1
		)
	return terrains


static func get_astar_path(
	start: Terrain,
	end: Terrain,
	terrains: Array[Terrain],
	unit: Unit,
	end_can_be_outside: bool = false
) -> PackedVector2Array:
	var astar: AStar2D = AStar2D.new()
	var filter_distance: bool = !end_can_be_outside
	terrains = filter_terrains(terrains, unit, true, filter_distance)
	# add end back in list even when a enemy unit is there (so long distance moves are possible)
	if not end_can_be_outside:
		if not end in terrains:
			return PackedVector2Array()
		if not end in terrains:
			terrains.append(end)
	var index: int = 0
	var points: Dictionary = {}
	for i: Terrain in terrains:
		var weight: int = i.get_movement_cost(unit, GameConst.Weather.CLEAR)
		if weight >= 0:
			points[i] = index
			astar.add_point(index, i.position, weight)
		index += 1
	for terrain: Terrain in points.keys():
		var p1: int = points[terrain]
		if terrain.get_up() in points:
			var p2: int = points[terrain.get_up()]
			astar.connect_points(p1, p2)
		if terrain.get_down() in points:
			var p2: int = points[terrain.get_down()]
			astar.connect_points(p1, p2)
		if terrain.get_left() in points:
			var p2: int = points[terrain.get_left()]
			astar.connect_points(p1, p2)
		if terrain.get_right() in points:
			var p2: int = points[terrain.get_right()]
			astar.connect_points(p1, p2)
	var start_point: int = points[start]
	var end_point: int = points[end]
	var result: PackedVector2Array = astar.get_point_path(start_point, end_point)
	return result


static func get_astar_path_as_terrains(
	start: Terrain,
	end: Terrain,
	terrains: Array[Terrain],
	unit: Unit,
	end_can_be_outside: bool = false
) -> Array[Terrain]:
	var _global: GlobalGlobal = Global
	var result: PackedVector2Array = get_astar_path(start, end, terrains, unit, end_can_be_outside)
	var result_terrains: Array[Terrain] = []
	for pos: Vector2 in result:
		result_terrains.append(_global.last_loaded_map.get_terrain_by_position(pos))
	return result_terrains


func get_movement_cost(unit: Unit, weather: GameConst.Weather) -> int:
	var movement_type: String = _types.movement_types[unit.values.movement_type]
	return _types.movements[id]["CLEAR"][movement_type]


func get_move_on_global_position() -> Vector2:
	return global_position


func has_unit() -> bool:
	for i: Node in get_children():
		if i is Unit:
			return true
	return false


func get_unit() -> Unit:
	for i: Node in get_children():
		if i is Unit:
			return i as Unit
	return null


# returns how many fields it's away (ignoring diagonal and "not movable terrains")
func get_none_diagonal_distance(to: Terrain) -> int:
	var distance: Vector2i = to.global_position - global_position
	distance /= ProjectSettings.get_setting("global/grid_size")
	var value: float = abs(distance.x) + abs(distance.y)
	return round(value)


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
	var pos: Vector2i = (
		global_position + Vector2.UP * ProjectSettings.get_setting("global/grid_size").y
	)
	return get_map().get_terrain_by_position(pos)


func get_down() -> Terrain:
	var pos: Vector2i = (
		global_position + Vector2.DOWN * ProjectSettings.get_setting("global/grid_size").y
	)
	return get_map().get_terrain_by_position(pos)


func get_left() -> Terrain:
	var pos: Vector2i = (
		global_position + Vector2.LEFT * ProjectSettings.get_setting("global/grid_size").y
	)
	return get_map().get_terrain_by_position(pos)


func get_right() -> Terrain:
	var pos: Vector2i = (
		global_position + Vector2.RIGHT * ProjectSettings.get_setting("global/grid_size").y
	)
	return get_map().get_terrain_by_position(pos)


func is_neighbor(terrain: Terrain) -> bool:
	return (
		terrain.get_up() == self
		or terrain.get_down() == self
		or terrain.get_left() == self
		or terrain.get_right() == self
	)


func get_map() -> Map:
	if get_parent() is Map:
		var map: Map = get_parent()
		return map
	return null


func is_on_map() -> bool:
	return get_map() != null


func _ready() -> void:
	if not sprite.material:
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = _shader_resource
		sprite.material = shader_material
	# Add shop units
	shop_units.clear()
	for unit_id: String in values.shop_units:
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
		if is_on_map():
			get_map().terrains.append(self)


func _exit_tree() -> void:
	remove_from_group("terrain")
	if is_on_map():
		get_map().terrains.erase(self)


func _update_color() -> void:
	if _types.terrains[id]["can_capture"]:
		if player_owned:
			shader_modulate = true
			color = player_owned.color
		else:
			shader_modulate = true
			var neutral_color: Color = ProjectSettings.get_setting("game/neutral_color")
			color = neutral_color


class Values extends NumberFix:
	var name: String
	var description: String
	var defense: int
	var health: int
	var can_capture: bool
	var capture_value: int
	var funds: int
	var ammo: int
	var shop_units: Array[String]
