class_name MapSelectableElement
extends SelectableElement

signal map_selected(map_json: String)

@export var map_json: String


func _ready() -> void:
	super()
	($SelectOverlay as Control).hide()
	var map: Map = MapFile.deserialize(map_json)
	(%Title as Label).text = map.map_name
	map.queue_free()


func _on_selected() -> void:
	map_selected.emit(map_json)
