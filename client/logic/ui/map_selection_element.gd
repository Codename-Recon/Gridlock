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

var map_json: String
var scenario_json: String

@onready var title: Label = $Element/Title
@onready var select_overlay: ColorRect = $SelectOverlay


func _ready() -> void:
	super()
	select_overlay.hide()
	var map: Map = MapFile.deserialize(map_json)
	title.text = map.map_name
	map.queue_free()


func _on_selected() -> void:
	map_selected.emit(map_json, scenario_json)
