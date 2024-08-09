class_name ShopElement
extends SelectableElement

signal unit_selected

@export var unit_scene: PackedScene

var unit_color: Color
var _unit: Unit

@onready var spawn_spot: Marker2D = $Element/UnitWindow/SubViewportContainer/SubViewport/SpawnSpot
@onready var title: Label = $Element/Title
@onready var body: Label = $Element/Body
@onready var cost: Label = $Element/Cost
@onready var select_overlay: ColorRect = $SelectOverlay

func _ready() -> void:
	super()
	select_overlay.hide()
	_unit = unit_scene.instantiate()
	_unit.color = unit_color

	title.text = tr(_unit.id)
	body.text = tr(_unit.values.description)
	cost.text = str(_unit.values.cost)
	spawn_spot.add_child(_unit)
	_unit.stats.hide()


func _on_selected() -> void:
	unit_selected.emit(unit_scene)
