class_name ShopElement
extends SelectableElement

signal unit_selected

@export var unit_scene: PackedScene

var unit_color: Color

var _unit: Unit
var _types: GlobalTypes = Types


func _ready() -> void:
	super()
	($SelectOverlay as ColorRect).hide()
	_unit = unit_scene.instantiate()
	_unit.color = unit_color

	(%Title as Label).text = tr(str(_types.units[_unit.id]["name"]))
	(%Body as Label).text = tr(str(_types.units[_unit.id]["description"]))
	(%Cost as Label).text = str(_types.units[_unit.id]["cost"])
	%SpawnSpot.add_child(_unit)
	_unit.stats.hide()


func _on_selected() -> void:
	unit_selected.emit(unit_scene)
