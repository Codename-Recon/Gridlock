extends Node
class_name GlobalGlobal

@export var selected_map: PackedScene

signal settings_changed

const CONFIG_SECTION: String = "game"
const RENDERING_SECTION: String = "rendering"

var last_player_won_name: String = "X"
var last_player_won_color: Color = Color.GREEN

var game_scene: PackedScene = load("res://levels/game.tscn")
var menu_scene: PackedScene = load("res://levels/menu.tscn")
var gameover_scene: PackedScene = load("res://levels/game_over_screen.tscn")

var config: ConfigFile = ConfigFile.new()

func save_config(key: String, value: Variant, section: String = CONFIG_SECTION) -> void:
	config.set_value(section, key, value)
	config.save("user://config.cfg")

func _ready() -> void:
	config.load("user://config.cfg")
