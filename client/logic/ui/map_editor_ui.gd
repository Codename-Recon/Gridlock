extends Control

signal terrain_selected(terrain_set: int, terrain: int)
signal unit_selected(unit_id: String, unit_scene: PackedScene)
signal edit_selected()
signal remove_selected()
signal map_resized(new_size: Vector2i)

@export var tile_set: TileSet
@export var game_input: GameInput
@export var map: Map

@onready var main_menu: Control = $MainMenu
@onready var terrain_container: GridContainer = $TabBar/TerrainPanel/TerrainContainer
@onready var unit_container: GridContainer = $TabBar/UnitPanel/UnitContainer
@onready var resize_menu: Control = $ResizeMenu
@onready var gray_background: ColorRect = $GrayBackground
@onready var edit: GameButton = $Edit
@onready var remove: GameButton = $Remove
@onready var map_settings: Panel = $MapSettings
@onready var name_line: LineEdit = %NameLine
@onready var author_line: LineEdit = %AuthorLine
@onready var player_option_button: OptionButton = %PlayerOptionButton
@onready var terrain_owner_option_button: OptionButton = %TerrainOwnerOptionButton
@onready var unit_owner_option_button: OptionButton = %UnitOwnerOptionButton

var _last_button: Button


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
		for unit_key: String in Map.predefined_units_packed_scenes:
			var unit_scene: PackedScene = Map.predefined_units_packed_scenes[unit_key]
			var button: Button = Button.new()
			button.text = unit_key
			button.pressed.connect(func() -> void: _on_unit_selected(button, unit_key, unit_scene))
			unit_container.add_child(button)
	_generate_player_options(player_option_button)
	_generate_player_options(terrain_owner_option_button)
	_generate_player_options(unit_owner_option_button)


func _generate_player_options(option: OptionButton) -> void:
	for i: int in option.item_count:
		option.remove_item(0)
	var i: int = 1
	for color: Color in ProjectSettings.get_setting("game/player_color"):
		var icon: GradientTexture2D = GradientTexture2D.new()
		icon.height = 16
		icon.width = 16
		icon.gradient = Gradient.new()
		icon.gradient.remove_point(1)
		icon.gradient.set_color(0, color)
		option.add_icon_item(icon, "%s %s" % [tr("PLAYER"), i])
		i += 1
	


func _change_activation_of_buttons(active_button: Button) -> void:
	if _last_button:
		_last_button.disabled = false
	_last_button = active_button
	_last_button.disabled = true


func _on_terrain_selected(button: Button, terrain_idx: int) -> void :
	terrain_selected.emit(0, terrain_idx)
	_change_activation_of_buttons(button)
	
	
func _on_unit_selected(button: Button, unit_id: String, unit_scene: PackedScene) -> void :
	unit_selected.emit(unit_id, unit_scene)
	_change_activation_of_buttons(button)


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


func _on_edit_pressed() -> void:
	edit_selected.emit()
	_change_activation_of_buttons(edit)


func _on_remove_pressed() -> void:
	remove_selected.emit()
	_change_activation_of_buttons(remove)


func _on_map_settings_mouse_entered() -> void:
	game_input.camera_movement_enabled = false


func _on_map_settings_mouse_exited() -> void:
	game_input.camera_movement_enabled = true
