class_name MapSelectableElement
extends SelectableElement

signal map_selected

@export var map_scene: PackedScene

var _map: Map


func _ready() -> void:
	super()
	($SelectOverlay as Control).hide()
	_map = map_scene.instantiate()
	(%Title as Label).text = _map.map_name


func _on_selected() -> void:
	map_selected.emit(map_scene)
