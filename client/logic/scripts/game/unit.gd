@icon("res://assets/images/icons/car-outline.svg")
@tool
class_name Unit
extends Node2D

signal unit_moved
signal damage_animated
signal attack_animation_done
signal refill_animation_done
signal possible_terrains_to_move_calculated
signal died

@export var shader_modulate: bool = false:
	set(value):
		if value:
			shader_modulate = value
			for i: Node in get_children():
				if "Sprite2D" in i.name:
					((i as Sprite2D).material as ShaderMaterial).set_shader_parameter("shifting", value)

@export_color_no_alpha var color: Color:
	set(value):
		if value:
			color = value
			var color_a: Color = Color(color, 1)
			for i: Node in get_children():
				if "Sprite2D" in i.name:
					((i as Sprite2D).material as ShaderMaterial).set_shader_parameter("new_color", color_a)

@export var player_owned: Player:
	set(value):
		player_owned = value
		if value:
			self.shader_modulate = true
			self.color = value.color

@export var properties: UnitProperty

@export var move_curve: Curve2D:
	set(value):
		if not Engine.is_editor_hint():
			if value:
				move_curve = value.duplicate()
				move_curve.remove_point(0)
				if has_node("AudioMove"):
					_audio_move.play()
				# to prevent emitting moved signal too fast the first move step should be called some time later (deferred). this is importand when moving on the same spot.
				_move_one_step_in_curve.call_deferred()

# Node which holds carried units 
@export var cargo: Node

var _possible_terrains_to_move_buffer: Array[Terrain]
var _possible_terrains_to_move_calculating: bool

@onready var _unit_stats: UnitStats = $UnitStats as UnitStats
@onready var _animation_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D as Sprite2D
@onready var _audio_move: AudioStreamPlayer2D = $AudioMove as AudioStreamPlayer2D

func get_possible_terrains_to_move() -> Array[Terrain]:
	if _possible_terrains_to_move_calculating:
		await possible_terrains_to_move_calculated
	return _possible_terrains_to_move_buffer

func calculate_possible_terrains_to_move() -> void:
	_possible_terrains_to_move_calculating = true
	var parent: Terrain = get_terrain()
	_possible_terrains_to_move_buffer = []
	# fuel limits possible movement steps
	var possible_movement_steps: int
	if properties.movement_points < get_unit_stats().fuel:
		possible_movement_steps = properties.movement_points
	else:
		possible_movement_steps = get_unit_stats().fuel
	_move(parent, _possible_terrains_to_move_buffer, possible_movement_steps, Vector2.ZERO, 0)
	_possible_terrains_to_move_calculating = false
	possible_terrains_to_move_calculated.emit()

func get_possible_terrains_to_attack_from_terrain(start_terrain: Terrain) -> Array[Terrain]:
	var terrains: Array[Terrain] = []
	_attack(start_terrain, terrains, properties.max_range, Vector2.ZERO, 0)
	return terrains

func get_neighbors_from_terrain(start_terrain: Terrain) -> Array[Terrain]:
	var terrains:Array[Terrain] = []
	terrains.append(start_terrain.get_up())
	terrains.append(start_terrain.get_down())
	terrains.append(start_terrain.get_left())
	terrains.append(start_terrain.get_right())
	return terrains

func get_unit_stats() -> UnitStats:
	return $UnitStats as UnitStats

func refill() -> void:
	var sound: GlobalSound = Sound as GlobalSound
	sound.play("Refill")
	_unit_stats.fuel = properties.fuel
	_unit_stats.ammo = properties.ammo

func repair(health: int) -> void:
	var sound: GlobalSound = Sound as GlobalSound
	sound.play("Repair")
	_unit_stats.health += health

# capture building on terrain currently standing on. returns true on success
func capture() -> bool:
	_unit_stats.capturing = true
	if get_terrain().capture(_unit_stats.health, player_owned):
		_unit_stats.capturing = false
		return true
	else:
		return false

func uncapture() -> void:
	_unit_stats.capturing = false
	get_terrain().uncapture()

func is_capturing() -> bool:
	return _unit_stats.capturing

func get_terrain() -> Terrain:
	return (get_parent() as Terrain)

func is_on_terrain() -> bool:
	return get_terrain() != null

func play_attack() -> void:
	_animation_player.play("attack")

func play_damage() -> void:
	_animation_player.play("damage")

func play_die() -> void:
	_animation_player.play("die")

func play_refill() -> void:
	_animation_player.play("refill")

func look_at_plane_global(global_point_position: Vector2) -> void:
	pass

func look_at_plane_global_tween(global_point_position: Vector2) -> void:
	pass

func get_terrain_on_point(point: Vector2) -> Terrain:
	var terrains: Array[Node] = get_tree().get_nodes_in_group("terrain")
	terrains = terrains.filter(func(t: Terrain) -> bool: 
		var pos: Vector2 = t.global_position
		return round(pos.x) == round(point.x) and round(pos.y) == round(point.y))
	var terrain: Terrain
	if len(terrains) > 0:
		terrain = terrains[0]
	else:
		terrain = null
	return terrain

func _ready() -> void:
	z_index = 1
	if not Engine.is_editor_hint():
		get_unit_stats().round_over_changed.connect(_round_over_changed)
		add_to_group("unit")
		_set_unit_stars()
		calculate_possible_terrains_to_move.call_deferred()
		_sprite.modulate = Color.WHITE

func _enter_tree() -> void:
	# if it's terrain
	if get_parent().has_method("get_move_on_global_position"):
		global_position = (get_parent() as Terrain).get_move_on_global_position()

func _round_over_changed() -> void:
	if(get_unit_stats().round_over):
		_sprite.modulate = ProjectSettings.get_setting("global/round_overlay")
	else:
		_sprite.modulate = Color.WHITE

func _attack(start: Terrain, terrains: Array, distance_left: int, direction: Vector2, step: int) -> void:
	if start:
		if step > 0:
			distance_left -= 1
			if distance_left < 0:
				return
		if not start in terrains and distance_left < properties.min_range:
			terrains.append(start)
		if step == 0:
			_attack(start.get_up(), terrains, distance_left, Vector2.UP, step + 1)
			_attack(start.get_down(), terrains, distance_left, Vector2.DOWN, step + 1)
			_attack(start.get_left(), terrains, distance_left, Vector2.LEFT, step + 1)
			_attack(start.get_right(), terrains, distance_left, Vector2.RIGHT, step + 1)
		else:
			if direction == Vector2.UP:
				_attack(start.get_up(), terrains, distance_left, direction, step + 1)
				_attack(start.get_left(), terrains, distance_left, Vector2.LEFT, step + 1)
				_attack(start.get_right(), terrains, distance_left, Vector2.RIGHT, step + 1)
			if direction == Vector2.DOWN:
				_attack(start.get_down(), terrains, distance_left, direction, step + 1)
				_attack(start.get_left(), terrains, distance_left, Vector2.LEFT, step + 1)
				_attack(start.get_right(), terrains, distance_left, Vector2.RIGHT, step + 1)
			if direction == Vector2.LEFT:
				_attack(start.get_left(), terrains, distance_left, Vector2.LEFT, step + 1)
			if direction == Vector2.RIGHT:
				_attack(start.get_right(), terrains, distance_left, Vector2.RIGHT, step + 1)

func _move(start: Terrain, terrains: Array, movement_left: int, direction: Vector2, step: int, allow_backwards: bool = false) -> void:
	if start:
		if step > 0:
			var movement_cost: int = start.properties.get_movement_cost(properties.movement_type)
			# movement cost -1 means not possible to use this terrain
			if movement_cost < 0 or (start.has_unit() and start.get_unit().player_owned != player_owned):
				return
			movement_left -= movement_cost
			if movement_left < 0:
				return
		if not start in terrains:
			terrains.append(start)
		# block testing "backwards"
		if step == 0:
			# if a unit is next to the moving unit, this direction has to be tested backwards too, so the unit can "go around" the blocking unit
			# TODO: this can be enhanced by checking if the unit is really a blocking unit
			var up_down_backwards: bool = (start.get_left() and start.get_left().has_unit()) or (start.get_right() and start.get_right().has_unit())
			var left_right_backwards: bool = (start.get_up() and start.get_up().has_unit()) or (start.get_down() and start.get_down().has_unit())
			_move(start.get_up(), terrains, movement_left, Vector2.UP, step + 1, up_down_backwards)
			_move(start.get_down(), terrains, movement_left, Vector2.DOWN, step + 1, up_down_backwards)
			_move(start.get_left(), terrains, movement_left, Vector2.LEFT, step + 1, left_right_backwards)
			_move(start.get_right(), terrains, movement_left, Vector2.RIGHT, step + 1, left_right_backwards)
		else:
			# only 3 steps are needet to go around a blocking unit
			if step > 3:
				allow_backwards = false
			if direction != Vector2.DOWN or allow_backwards:
				_move(start.get_up(), terrains, movement_left, direction, step + 1, allow_backwards)
			if direction != Vector2.UP or allow_backwards:
				_move(start.get_down(), terrains, movement_left, direction, step + 1, allow_backwards)
			if direction != Vector2.RIGHT or allow_backwards:
				_move(start.get_left(), terrains, movement_left, direction, step + 1, allow_backwards)
			if direction != Vector2.LEFT or allow_backwards:
				_move(start.get_right(), terrains, movement_left, direction, step + 1, allow_backwards)

func _move_one_step_in_curve() -> void:
	if not Engine.is_editor_hint():
		if move_curve:
			if move_curve.get_point_count() > 0:
				var point: Vector2 = move_curve.get_point_position(0)
				var terrain: Terrain = get_terrain_on_point(point)
				point = terrain.get_move_on_global_position()
				move_curve.remove_point(0)
				look_at_plane_global(point)
				var tween: Tween = create_tween()
				tween.tween_property(self, "global_position", point, 0.2)
				tween.tween_callback(_move_one_step_in_curve)
				get_unit_stats().fuel -= 1
			else:
				_end_move()

func _end_move() -> void:
	var terrain: Terrain = get_terrain_on_point(global_position)
	var tmp_transform: Transform3D = global_transform
	get_parent().remove_child(self)
	terrain.add_child(self)
	global_transform = tmp_transform
	move_curve = null
	_set_unit_stars()
	calculate_possible_terrains_to_move.call_deferred()
	if has_node("AudioMove"):
		_audio_move.stop()
	unit_moved.emit()

func _set_unit_stars() -> void:
	if _unit_stats and is_on_terrain():
		_unit_stats.star_number = get_terrain().properties.defence_level
