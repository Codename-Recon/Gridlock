class_name UserSelectableElement
extends SelectableElement

signal user_selected

@export var user_name: String

@onready var name_label: Label = $Element/NameLabel


func _ready() -> void:
	super()
	name_label.text = user_name


func _on_selected() -> void:
	pass
