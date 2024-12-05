class_name MapSelectableElement
extends SelectableElement

signal map_selected(map_json: String, scenario_json: String)

enum IconType{
	MAP,
	LOCKED,
	UNKNOWN_RANK,
	C_RANK,
	B_RANK,
	A_RANK,
	S_RANK
}

@export var icons: Array[Texture]

var icon: IconType:
	set(value):
		icon = value
		icon_rect.texture = icons[int(value)]

var _global: GlobalGlobal = Global

var game_mode: GameConst.GameMode
var map_json: String
var scenario_json: String

@onready var title: Label = $Element/Title
@onready var select_overlay: ColorRect = $SelectOverlay
@onready var icon_rect: TextureRect = $Element/IconWindow/Panel/IconRect


func lock() -> void:
	icon = IconType.LOCKED
	deactivated = true

func _ready() -> void:
	super()
	select_overlay.hide()
	var map: Map = MapFile.deserialize(map_json)
	title.text = map.map_name
	map.queue_free()
	match game_mode:
		GameConst.GameMode.BOOTCAMP:
			var scenario: Scenario = ScenarioFile.deserialize(scenario_json)
			if _global.has_scenario_progress(scenario.id):
				var progress: GlobalGlobal.ScenarioProgress = _global.load_scenario_progress(scenario.id)
				if progress.score < 500:
					icon = IconType.C_RANK
				elif progress.score < 1000:
					icon = IconType.B_RANK
				elif progress.score < 1500:
					icon = IconType.A_RANK
				else:
					icon = IconType.S_RANK
			else:
				icon = IconType.UNKNOWN_RANK


func _on_selected() -> void:
	map_selected.emit(map_json, scenario_json)
