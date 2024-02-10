class_name ShopElement
extends SelectableElement

signal unit_selected

@export var unit_scene: PackedScene

var _unit: Unit


func _ready() -> void:
	super()
	($SelectOverlay as ColorRect).hide()
	_unit = (unit_scene.instantiate() as Unit)
	_unit.get_unit_stats().hide()
	(%Title as Label).text = tr(_unit.properties.name)
	(%Body as Label).text = tr(_unit.properties.description)
	(%Cost as Label).text = str(_unit.properties.cost)
	%SpawnSpot.add_child(_unit)


func _on_selected() -> void:
	unit_selected.emit(unit_scene)
