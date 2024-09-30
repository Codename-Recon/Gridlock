@icon("res://assets/images/icons/nodes/car-outline.svg")
@tool
class_name Unit
extends Node2D

signal unit_moved
@warning_ignore("unused_signal")
signal damage_animated(radius: int)
@warning_ignore("unused_signal")
signal attack_animation_done
@warning_ignore("unused_signal")
signal refill_animation_done
signal possible_terrains_to_move_calculated
@warning_ignore("unused_signal")
signal died

enum State { STANDING, MOVING, ATTACKING, DAMAGING, DYING, REFILLING }

const WEAPON_TYPE_TRANSLATION: Dictionary = {
	GameConst.WeaponType.MACHINE_GUN: "gunattack",
	GameConst.WeaponType.VULCAN_CANNON: "vulcan_cannon",
	GameConst.WeaponType.MISSILE: "small_explosion",
	GameConst.WeaponType.ROCKET: "explosion",
	GameConst.WeaponType.SMALL_CANNON: "small_explosion",
	GameConst.WeaponType.BIG_CANNON: "explosion",
	GameConst.WeaponType.TORPEDO: "torpedo",
	GameConst.WeaponType.BOMB: "bomb"
}

const ATTACKS: PackedScene = preload("res://logic/game/effects/attacks.tscn")

@export var shader_modulate: bool = false:
	set(value):
		if value:
			shader_modulate = value
			for i: Node in get_children():
				if "Sprite2D" in i.name:
					((i as Node2D).material as ShaderMaterial).set_shader_parameter(
						"shifting", value
					)

@export_color_no_alpha var color: Color:
	set(value):
		if value:
			color = value
			var color_a: Color = Color(color, 1)
			for i: Node in get_children():
				if "Sprite2D" in i.name:
					((i as Node2D).material as ShaderMaterial).set_shader_parameter(
						"new_color", color_a
					)

@export var player_owned: Player:
	set(value):
		player_owned = value
		_update_color()

@export var id: String

@export var move_curve: Curve2D:
	set(value):
		if not Engine.is_editor_hint():
			if value:
				move_curve = value.duplicate()
				if has_node("AudioMove"):
					_audio_move.play()
				# to prevent emitting moved signal too fast the first move step should be called some time later (deferred). this is importand when moving on the same spot.
				_move_on_curve.call_deferred()

var cargo: Node
var values: Values:
	get:
		if not values:
			# Load values from types
			var values_dic: Dictionary = _types.units[id]
			values_dic["@path"] = "res://logic/game/units/unit.gd"
			values_dic["@subpath"] = "Values"
			values = dict_to_inst(values_dic)
			values.fix()
		return values

var movement_type: String:
	get:
		if not movement_type:
			movement_type = _types.movement_types[values.movement_type]
		return movement_type

var carrying_types: Array[String]:
	get:
		if not carrying_types:
			carrying_types = []
			for type: int in values.carrying_types:
				carrying_types.append(_types.unit_types[type])
		return carrying_types

var weapons: Array[String]:
	get:
		if not weapons:
			weapons = []
			for weapon: int in values.weapons:
				weapons.append(_types.weapon_types[weapon])
		return weapons

## Counts for fuel too
var possible_movement_steps: int:
	get:
		if values.mp < stats.fuel:
			return values.mp
		return stats.fuel

var last_damage_type: GameConst.WeaponType

var _possible_terrains_to_move_buffer: Array[Terrain]
var _possible_terrains_to_move_calculating: bool
var _last_position: Vector2 = position
var _state: State = State.STANDING

var _types: GlobalTypes = Types
var _global: GlobalGlobal = Global

@onready var stats: UnitStats = $UnitStats
@onready var sprite: Node2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _audio_move: AudioStreamPlayer2D = $AudioMove


func get_texture() -> Texture:
	if sprite is AnimatedSprite2D:
		var animation_sprite: AnimatedSprite2D = sprite
		return animation_sprite.sprite_frames.get_frame_texture("default", 0)
	if sprite is Sprite2D:
		var sprite2d: Sprite2D = sprite
		return sprite2d.texture
	return null


func get_shader_material() -> ShaderMaterial:
	if sprite is AnimatedSprite2D:
		var animation_sprite: AnimatedSprite2D = sprite
		return animation_sprite.material
	if sprite is Sprite2D:
		var sprite2d: Sprite2D = sprite
		return sprite2d.material
	return null


func get_possible_terrains_to_move() -> Array[Terrain]:
	if _possible_terrains_to_move_calculating:
		await possible_terrains_to_move_calculated
	return _possible_terrains_to_move_buffer


func _lamda_calculate_distance(a: Terrain, b: Terrain) -> bool:
	var value_a: int = a.get_none_diagonal_distance(get_terrain())
	var value_b: int = b.get_none_diagonal_distance(get_terrain())
	return value_a > value_b


func calculate_possible_terrains_to_move() -> void:
	if not _global.loaded_map or not is_on_map():
		_possible_terrains_to_move_buffer = []
		possible_terrains_to_move_calculated.emit()
		return
	_possible_terrains_to_move_calculating = true
	var terrains: Array[Terrain] = _global.loaded_map.terrains
	terrains = Terrain.filter_movable_terrains(terrains, self, true, true)

	# Sort by distance; First entry is the farthest terrain
	terrains.sort_custom(_lamda_calculate_distance)
	var movable_terrains: Array[Terrain] = []
	while terrains.size() > 0:
		var terrain: Terrain = terrains[0]
		terrains.erase(terrain)
		var path: Array[Terrain] = Terrain.get_astar_path_as_terrains(
			get_terrain(), terrain, _global.loaded_map.terrains, self
		)
		var cost: int = -get_terrain().get_movement_cost(self, GameConst.Weather.CLEAR)
		for t: Terrain in path:
			cost += t.get_movement_cost(self, GameConst.Weather.CLEAR)
			if cost > possible_movement_steps:
				break
			movable_terrains.append(t)
			terrains.erase(t)

	_possible_terrains_to_move_buffer = movable_terrains
	_possible_terrains_to_move_calculating = false
	possible_terrains_to_move_calculated.emit()


func get_neighbors_from_terrain(start_terrain: Terrain) -> Array[Terrain]:
	var terrains: Array[Terrain] = []
	terrains.append(start_terrain.get_up())
	terrains.append(start_terrain.get_down())
	terrains.append(start_terrain.get_left())
	terrains.append(start_terrain.get_right())
	return terrains


func refill() -> void:
	var sound: GlobalSound = Sound as GlobalSound
	sound.play("Refill")
	stats.fuel = values.fuel
	stats.ammo = values.ammo


func repair(health: int) -> void:
	var sound: GlobalSound = Sound as GlobalSound
	sound.play("Repair")
	stats.health += health


# capture building on terrain currently standing on. returns true on success
func capture() -> bool:
	stats.capturing = true
	if get_terrain().capture(stats.health, player_owned):
		stats.capturing = false
		return true
	else:
		return false


func uncapture() -> void:
	stats.capturing = false
	get_terrain().uncapture()


func is_capturing() -> bool:
	return stats.capturing


func get_terrain() -> Terrain:
	return get_parent() as Terrain


func is_on_terrain() -> bool:
	return get_terrain() != null


func get_map() -> Map:
	if not is_on_terrain():
		return null
	if not get_terrain().get_parent() is Map:
		return null
	var map: Map = get_terrain().get_parent()
	return map


func is_on_map() -> bool:
	return get_map() != null


func play_attack(weapon_category: GameConst.WeaponCategory) -> void:
	_state = State.ATTACKING
	if weapon_category == GameConst.WeaponCategory.PRIMARY:
		_animation_player.play("attack_primary")
	elif weapon_category == GameConst.WeaponCategory.SECONDARY:
		_animation_player.play("attack_secondary")
	await _animation_player.animation_finished
	play_idle()


## Function for damage animated signal.
## [br]
## The effect is placed in a randomly position
## within a distance of [param box_size] from the units origin position.
func play_damage(box_size: Vector2 = Vector2.ZERO) -> void:
	_state = State.DAMAGING
	_animation_player.play("struck")
	var effect: Effect = ATTACKS.instantiate()
	add_child(effect)
	var random_position: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	random_position *= box_size
	effect.position = random_position
	var animation: String = WEAPON_TYPE_TRANSLATION[last_damage_type]
	effect.player.play(animation)
	await _animation_player.animation_finished
	play_idle()


func play_die() -> void:
	_state = State.DYING
	_animation_player.play("die")
	await _animation_player.animation_finished
	play_idle()


func play_refill() -> void:
	_state = State.REFILLING
	_animation_player.play("refill")
	await _animation_player.animation_finished
	play_idle()


func play_idle() -> void:
	_state = State.STANDING
	if stats.health > ProjectSettings.get_setting("global/unit/injured_threshold"):
		_animation_player.play("idle")
	else:
		_animation_player.play("idle_injured")


func _init() -> void:
	pass


func _ready() -> void:
	z_index = 2
	if not Engine.is_editor_hint():
		stats.round_over_changed.connect(_round_over_changed)
		add_to_group("unit")
		_set_unit_stars()
		calculate_possible_terrains_to_move.call_deferred()
		sprite.modulate = Color.WHITE
		_update_color()
		if has_node("Cargo"):
			cargo = $Cargo


func _process(delta: float) -> void:
	var direction: Vector2 = global_position - _last_position
	if _state == State.MOVING or _state == State.STANDING:
		if direction.length_squared() > 0.001:
			_state = State.MOVING
			if abs(direction.angle_to(Vector2.UP)) < 0.01:
				if _animation_player.has_animation("moving_up"):
					_animation_player.play("moving_up")
			elif abs(direction.angle_to(Vector2.DOWN)) < 0.01:
				if _animation_player.has_animation("moving_down"):
					_animation_player.play("moving_down")
			elif abs(direction.angle_to(Vector2.LEFT)) < 0.01:
				if _animation_player.has_animation("moving_left"):
					_animation_player.play("moving_left")
			elif abs(direction.angle_to(Vector2.RIGHT)) < 0.01:
				if _animation_player.has_animation("moving_right"):
					_animation_player.play("moving_right")
			_last_position = global_position
		else:
			if _state != State.STANDING:
				play_idle()


func _enter_tree() -> void:
	if is_on_map():
		get_map().units.append(self)
	if is_on_terrain():
		global_position = (get_parent() as Terrain).get_move_on_global_position()


func _exit_tree() -> void:
	if is_on_map():
		get_map().units.erase(self)


func _round_over_changed() -> void:
	if stats.round_over:
		sprite.modulate = ProjectSettings.get_setting("global/round_overlay")
	else:
		sprite.modulate = Color.WHITE


func _move_on_curve() -> void:
	if not Engine.is_editor_hint():
		if move_curve:
			var path: Path2D = Path2D.new()
			path.curve = move_curve
			get_terrain().get_parent().add_child(path)
			var follow: PathFollow2D = PathFollow2D.new()
			follow.rotates = false
			path.add_child(follow)
			reparent(follow)
			var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(
				Tween.EASE_IN_OUT
			)
			var time: float = ProjectSettings.get_setting("global/unit/move_tween_time") as float
			tween.tween_property(follow, "progress_ratio", 1, time)
			stats.fuel -= move_curve.get_point_count() - 1
			await tween.finished
			_animation_player.play("RESET")
			_end_move()
			path.queue_free()
			follow.queue_free()


func _end_move() -> void:
	var terrain: Terrain = _global.loaded_map.get_terrain_by_position(global_position)
	var tmp_transform: Transform3D = global_transform
	reparent(terrain)
	global_transform = tmp_transform
	move_curve = null
	_set_unit_stars()
	calculate_possible_terrains_to_move.call_deferred()
	if has_node("AudioMove"):
		_audio_move.stop()
	unit_moved.emit()


func _set_unit_stars() -> void:
	if stats and is_on_terrain():
		stats.star_number = _types.terrains[get_terrain().id]["defense"]


func _update_color() -> void:
	if player_owned:
		shader_modulate = true
		color = player_owned.color
	else:
		shader_modulate = true
		var neutral_color: Color = ProjectSettings.get_setting("game/neutral_color")
		color = neutral_color


class Values:
	extends NumberFix
	var name: String
	var description: String
	var cost: int
	var health: int
	var mp: int
	var movement_type: int
	var fuel: int
	var turn_fuel: int
	var hidden_turn_fuel: int
	var vision: int
	var ammo: int
	var weapons: Array[int]
	var min_range: int
	var max_range: int
	var xp: int
	var can_supply: bool
	var can_repair: bool
	var can_capture: bool
	var can_move_and_attack: bool
	var can_hide: bool
	var can_dive: bool
	var carrying_types: Array[int]
	var carrying_size: int
