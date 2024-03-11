class_name Shop
extends Control

signal element_selected

@export_category("Internal")
@export var shop_element_scene: PackedScene

## Creates the shop elements with the color of the current player.
func create_shop_elements(units: Array[PackedScene], player: Player) -> void:
	for unit: PackedScene in units:
		var element: ShopElement = shop_element_scene.instantiate()
		element.unit_color = player.color
		element.unit_scene = unit
		element.unit_selected.connect(_on_element_clicked)
		%VBoxContainer.add_child(element)
		_add_v_split()
	hide()


func _add_v_split() -> void:
	var split: VSplitContainer = VSplitContainer.new()
	split.custom_minimum_size.y = ProjectSettings.get_setting("global/shop_element_vspace")
	%VBoxContainer.add_child(split)


func _on_close_pressed() -> void:
	element_selected.emit(null)
	hide()


func _on_element_clicked(unit: PackedScene) -> void:
	element_selected.emit(unit)
	hide()
