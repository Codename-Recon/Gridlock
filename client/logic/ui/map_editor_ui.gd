extends Control

signal terrain_selected(terrain_set: int, terrain: int)
signal unit_selected(unit_id: String, unit_scene: PackedScene)
signal edit_selected()
signal remove_selected()
signal map_resized(new_size: Vector2i)
signal map_settings_player_id_changed(player_id: int)

@export var tile_set: TileSet
@export var game_input: GameInput
@export var map: Map
@export var map_editor: MapEditor

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
@onready var terrain_settings_control: Control = %TerrainSettingsControl
@onready var unit_settings_control: Control = %UnitSettingsControl
@onready var terrain_texture_rect: TextureRect = %TerrainTextureRect
@onready var unit_texture_rect: TextureRect = %UnitTextureRect
@onready var h_box_container_terrain_owner: HSplitContainer = %HBoxContainerTerrainOwner


var _last_button: Button
var _last_terrain_edited: Terrain
var _last_unit_edited: Unit
var _types: GlobalTypes = Types


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
	map_editor.tile_edit_selected.connect(_on_tile_edit_selected)
	terrain_settings_control.hide()
	unit_settings_control.hide()


func _generate_player_options(option: OptionButton) -> void:
	for i: int in option.item_count:
		option.remove_item(0)
	var neutral_color: Color = ProjectSettings.get_setting("game/neutral_color")
	var icon: GradientTexture2D = GradientTexture2D.new()
	icon.height = 16
	icon.width = 16
	icon.gradient = Gradient.new()
	icon.gradient.remove_point(1)
	icon.gradient.set_color(0, neutral_color)
	option.add_icon_item(icon, tr("NEUTRAL"))
	var i: int = 1
	for color: Color in ProjectSettings.get_setting("game/player_color"):
		icon = GradientTexture2D.new()
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


func _on_tile_edit_selected(terrain: Terrain, unit: Unit) -> void:
	_last_terrain_edited = terrain
	_last_unit_edited = unit
	if _last_terrain_edited:
		terrain_settings_control.show()
		terrain_texture_rect.texture = _last_terrain_edited.sprite.texture
		h_box_container_terrain_owner.visible = _types.terrains[terrain.id]["can_capture"]
	else:
		terrain_settings_control.hide()
	if _last_unit_edited:
		unit_settings_control.show()
		unit_texture_rect.texture = _last_unit_edited.get_texture()
	else:
		unit_settings_control.hide()


func _on_player_option_button_item_selected(index: int) -> void:
	map_settings_player_id_changed.emit(index)
