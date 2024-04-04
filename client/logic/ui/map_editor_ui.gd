@tool
extends Control

signal terrain_selected(terrain_set: int, terrain: int)
signal unit_selected(unit_id: String, unit_scene: PackedScene)
signal map_resized(new_size: Vector2i)

@export var tile_set: TileSet
@export var game_input: GameInput
@export var map: Map

@onready var main_menu: Control = $MainMenu
@onready var terrain_container: GridContainer = $TabBar/TerrainPanel/TerrainContainer
@onready var unit_container: GridContainer = $TabBar/UnitPanel/UnitContainer
@onready var resize_menu: Control = $ResizeMenu
@onready var gray_background: ColorRect = $GrayBackground

var last_button: Button


func _ready() -> void:
	if tile_set:
		for child: Node in terrain_container.get_children():
			terrain_container.remove_child(child)
		for terrain_idx: int in range(tile_set.get_terrains_count(0)):
			var button: Button = Button.new()
			button.text = tile_set.get_terrain_name(0, terrain_idx)
			button.pressed.connect(func() -> void: _on_terrain_selected(button, terrain_idx))
			terrain_container.add_child(button)
	if map:
		for child: Node in unit_container.get_children():
			unit_container.remove_child(child)
		for unit_key: String in map.get_predefined_units_packed_scenes():
			var unit_scene: PackedScene = map.get_predefined_units_packed_scenes()[unit_key]
			var button: Button = Button.new()
			button.text = unit_key
			button.pressed.connect(func() -> void: _on_unit_selected(button, unit_key, unit_scene))
			unit_container.add_child(button)


func _on_terrain_selected(button: Button, terrain_idx: int) -> void :
	terrain_selected.emit(0, terrain_idx)
	if last_button:
		last_button.disabled = false
	last_button = button
	last_button.disabled = true
	
	
func _on_unit_selected(button: Button, unit_id: String, unit_scene: PackedScene) -> void :
	unit_selected.emit(unit_id, unit_scene)
	if last_button:
		last_button.disabled = false
	last_button = button
	last_button.disabled = true


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/menu.tscn")


func _on_game_input_input_escape() -> void:
	gray_background.visible = !gray_background.visible
	main_menu.visible = gray_background.visible
	# Block input while menu is shown
	game_input.selection_enabled = !main_menu.visible
	game_input.selection_movement_enabled = !main_menu.visible
	resize_menu.hide()


func _on_close_pressed() -> void:
	gray_background.hide()
	main_menu.hide()
	resize_menu.hide()
	game_input.selection_enabled = true
	game_input.selection_movement_enabled = true


func _on_map_resized(new_size: Vector2i) -> void:
	gray_background.hide()
	main_menu.hide()
	resize_menu.hide()
	game_input.selection_enabled = true
	game_input.selection_movement_enabled = true
