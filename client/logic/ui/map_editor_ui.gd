@tool
extends Control

signal select_terrain(terrain_set: int, terrain: int)
signal resize_map(new_size: Vector2i)

@export var tile_set: TileSet
@export var game_input: GameInput

@onready var main_menu: Control = $MainMenu
@onready var terrains_container: HBoxContainer = $Panel/TerrainsContainer
@onready var resize_menu: Control = $ResizeMenu
@onready var gray_background: ColorRect = $GrayBackground

var last_button: Button


func _ready() -> void:
	if tile_set:
		for child: Node in terrains_container.get_children():
			terrains_container.remove_child(child)
		for terrain_idx: int in range(tile_set.get_terrains_count(0)):
			var button: Button = Button.new()
			button.text = tile_set.get_terrain_name(0, terrain_idx)
			button.pressed.connect(func() -> void: on_terrain_selected(button, terrain_idx))
			terrains_container.add_child(button)


func on_terrain_selected(button: Button, terrain_idx: int) -> void :
	select_terrain.emit(0, terrain_idx)
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


func _on_resize_map(new_size: Vector2i) -> void:
	gray_background.hide()
	main_menu.hide()
	resize_menu.hide()
	game_input.selection_enabled = true
	game_input.selection_movement_enabled = true
