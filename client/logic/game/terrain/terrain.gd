@icon("res://assets/images/icons/flag-outline.svg")
@tool
class_name Terrain
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var shader_modulate: bool = false:
	set(value):
		if value && has_node("./Sprite2D"):
			shader_modulate = value
			var sprite: Sprite2D = $Sprite2D as Sprite2D
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
		if value:
			player_owned = value
			self.shader_modulate = true
			self.color = value.color

@export var id: String

@export var shop_units: Array[PackedScene]

# layer variable for color layer, handled that only one layer can be set (new layer overwrites old one)
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


# captures terrain. gives true back on success.
func capture(capture_force: int, player_of_unit: Player) -> bool:
	var stats: TerrainStats = $TerrainStats
	stats.capture_health -= capture_force
	if stats.capture_health <= 0:
		stats.reset_capture_health()
		player_owned = player_of_unit
		return true
	else:
		return false


func uncapture() -> void:
	var stats: TerrainStats = $TerrainStats
	stats.reset_capture_health()


func _ready() -> void:
	if not Engine.is_editor_hint():
		add_to_group("terrain")


func _set_color(set_color: Color) -> void:
	var sprite: Sprite2D = $Sprite2D as Sprite2D
	(sprite.material as ShaderMaterial).set_shader_parameter("new_color", set_color)


func _cast_collider(direction: Vector2) -> Area2D:
	var terrains: Array[Node] = get_tree().get_nodes_in_group("terrain")
	var test_position: Vector2 = (
		global_position + direction * ProjectSettings.get_setting("global/grid_size").y
	)
	terrains = terrains.filter(
		func(t: Node) -> bool: return (t as Terrain).global_position == test_position
	)
	var entity: Area2D
	if len(terrains) > 0:
		entity = terrains[0]
	else:
		entity = null
	return entity


func get_up() -> Terrain:
	var entity: Area2D = _cast_collider(Vector2.UP)
	if not entity is Terrain:
		entity = null
	return entity


func get_down() -> Terrain:
	var entity: Area2D = _cast_collider(Vector2.DOWN)
	if not entity is Terrain:
		entity = null
	return entity


func get_left() -> Terrain:
	var entity: Area2D = _cast_collider(Vector2.LEFT)
	if not entity is Terrain:
		entity = null
	return entity


func get_right() -> Terrain:
	var entity: Area2D = _cast_collider(Vector2.RIGHT)
	if not entity is Terrain:
		entity = null
	return entity


func is_neighbor(terrain: Terrain) -> bool:
	return (
		terrain.get_up() == self
		or terrain.get_down() == self
		or terrain.get_left() == self
		or terrain.get_right() == self
	)
