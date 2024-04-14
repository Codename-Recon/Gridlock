class_name MapEditorUI
extends Control

signal terrain_selected(terrain_set: int, terrain: int)
signal unit_selected(unit_id: String, unit_scene: PackedScene)
signal tile_selected(atlas_id: Vector2i)
signal edit_selected()
signal remove_selected()
signal map_resized(new_size: Vector2i)
signal map_settings_player_id_changed(player_id: int)
signal selected
signal save_selected
signal load_selected(file_path: String)

@export var tile_set: TileSet
@export var game_input: GameInput
@export var map: Map
@export var map_editor: MapEditor

@onready var main_menu: Control = $MainMenu
@onready var terrain_container: GridContainer = %TerrainContainer
@onready var unit_container: GridContainer = %UnitContainer
@onready var tile_container: FlowContainer = %TileContainer
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
@onready var h_box_container_money: HSplitContainer = %HBoxContainerMoney
@onready var money_spin: SpinBox = %MoneySpin
@onready var unit_health_spin: SpinBox = %UnitHealthSpin
@onready var unit_fuel_spin: SpinBox = %UnitFuelSpin
@onready var unit_ammo_spin: SpinBox = %UnitAmmoSpin
@onready var load_file_dialog: FileDialog = $LoadFileDialog


var _last_button: Button
var _last_terrain_edited: Terrain
var _last_unit_edited: Unit
var _types: GlobalTypes = Types

func reload_map_data() -> void:
	name_line.text = map.map_name
	author_line.text = map.author
	terrain_settings_control.hide()
	unit_settings_control.hide()
	_update_money_container()


func _ready() -> void:
	if tile_set:
		# Set terrain tab
		for child: Node in terrain_container.get_children():
			terrain_container.remove_child(child)
		for terrain_idx: int in range(tile_set.get_terrains_count(0)):
			var button: Button = Button.new()
			button.text = tile_set.get_terrain_name(0, terrain_idx)
			button.pressed.connect(func() -> void: _on_terrain_selected(button, terrain_idx))
			terrain_container.add_child(button)
		# Set tile tab
		for child: Node in tile_container.get_children():
			tile_container.remove_child(child)
		var source: TileSetAtlasSource = tile_set.get_source(0)
		for i: int in source.get_tiles_count():
			var atlas_coords: Vector2i = source.get_tile_id(i)
			var atlas: Texture2D = map_editor.get_texture_with_atlas_coords(atlas_coords)
			var button: Button = Button.new()
			button.icon = atlas
			button.pressed.connect(func() -> void: _on_tile_selected(button, atlas_coords))
			tile_container.add_child(button)
	if map:
		# Set unit tab
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
	map_editor.tile_edit_selected.connect(_on_tile_edit_selected, CONNECT_DEFERRED) # Deferred, to prevent value overwrite when switching between units because of focus release
	terrain_settings_control.hide()
	unit_settings_control.hide()
	_connect_text_boxes_for_focus()
	_update_money_container()


func _connect_text_boxes_for_focus() -> void:
	# Go through ALL children
	var waiting: Array[Node] = get_children()
	while not waiting.is_empty():
		var node: Node = waiting.pop_back()
		waiting.append_array(node.get_children())
		if node is LineEdit:
			var line_edit: LineEdit = node
			line_edit.focus_entered.connect(_on_line_focus_entered)
			line_edit.focus_exited.connect(_on_line_focus_exited)
			selected.connect(func() -> void: line_edit.release_focus())
			continue
		if node is SpinBox:
			var spin_box: SpinBox = node
			spin_box.get_line_edit().focus_entered.connect(_on_line_focus_entered)
			spin_box.get_line_edit().focus_exited.connect(_on_line_focus_exited)
			selected.connect(func() -> void: spin_box.get_line_edit().release_focus())
			continue


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


func _close_menu() -> void:
	gray_background.hide()
	main_menu.hide()
	resize_menu.hide()
	game_input.selection_enabled = true
	game_input.selection_movement_enabled = true

func _update_money_container() -> void:
	if map.has_player(player_option_button.selected):
		h_box_container_money.show()
		money_spin.value = map.get_player(player_option_button.selected).money
	else:
		h_box_container_money.hide()


func _on_terrain_selected(button: Button, terrain_idx: int) -> void :
	terrain_selected.emit(0, terrain_idx)
	_change_activation_of_buttons(button)
	
	
func _on_unit_selected(button: Button, unit_id: String, unit_scene: PackedScene) -> void :
	unit_selected.emit(unit_id, unit_scene)
	_change_activation_of_buttons(button)


func _on_tile_selected(button: Button, atlas_id: Vector2i) -> void:
	tile_selected.emit(atlas_id)
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
	_close_menu()


func _on_map_resized(new_size: Vector2i) -> void:
	_close_menu()


func _on_edit_pressed() -> void:
	edit_selected.emit()
	_change_activation_of_buttons(edit)


func _on_remove_pressed() -> void:
	remove_selected.emit()
	_change_activation_of_buttons(remove)


func _on_tile_edit_selected(terrain: Terrain, unit: Unit) -> void:
	#await get_tree().create_timer(0.01).timeout
	_last_terrain_edited = terrain
	_last_unit_edited = unit
	if _last_terrain_edited:
		terrain_settings_control.show()
		terrain_texture_rect.texture = _last_terrain_edited.sprite.texture
		if _types.terrains[terrain.id]["can_capture"]:
			h_box_container_terrain_owner.show()
			var player_id: int = 0
			if terrain.player_owned:
				player_id = terrain.player_owned.id
			terrain_owner_option_button.select(player_id)
		else:
			h_box_container_terrain_owner.hide()
	else:
		terrain_settings_control.hide()
	if _last_unit_edited:
		unit_settings_control.show()
		unit_texture_rect.texture = _last_unit_edited.get_texture()
		var player_id: int = 0
		if unit.player_owned:
			player_id = unit.player_owned.id
		unit_owner_option_button.select(player_id)
		unit_health_spin.value = unit.stats.health
		unit_fuel_spin.value = unit.stats.fuel
		unit_ammo_spin.value = unit.stats.ammo
	else:
		unit_settings_control.hide()


func _on_player_option_button_item_selected(index: int) -> void:
	map_settings_player_id_changed.emit(index)
	_update_money_container()


func _on_line_focus_entered() -> void:
	game_input.camera_movement_enabled = false


func _on_line_focus_exited() -> void:
	game_input.camera_movement_enabled = true


func _unhandled_input(event: InputEvent) -> void:
	if map_settings.visible:
		if event is InputEventMouseButton and event.is_action("select_first"):
			selected.emit()
			_update_money_container()

func _on_money_spin_value_changed(value: float) -> void:
	map.get_player(player_option_button.selected).money = value


func _on_terrain_owner_option_button_item_selected(index: int) -> void:
	map.change_terrain_owner(_last_terrain_edited, index)


func _on_unit_owner_option_button_item_selected(index: int) -> void:
	map.change_unit_owner(_last_unit_edited, index)


func _on_unit_health_spin_value_changed(value: float) -> void:
	_last_unit_edited.stats.health = value


func _on_unit_fuel_spin_value_changed(value: float) -> void:
	_last_unit_edited.stats.fuel = value


func _on_unit_ammo_spin_value_changed(value: float) -> void:
	_last_unit_edited.stats.ammo = value


func _on_name_line_text_changed(new_text: String) -> void:
	map.map_name = new_text


func _on_author_line_text_changed(new_text: String) -> void:
	map.author = new_text


func _on_save_pressed() -> void:
	_close_menu()
	save_selected.emit()


func _on_load_pressed() -> void:
	_close_menu()
	_disable_input()
	load_file_dialog.show()


func _on_load_file_dialog_canceled() -> void:
	_enable_input()


func _on_load_file_dialog_file_selected(path: String) -> void:
	_enable_input.call_deferred()
	load_selected.emit(path)


func _enable_input() -> void:
	game_input.camera_movement_enabled = true
	game_input.button_enabled = true
	game_input.selection_enabled = true
	

func _disable_input() -> void:
	game_input.camera_movement_enabled = false
	game_input.button_enabled = false
	game_input.selection_enabled = false
