extends SelectableElement
class_name UserSelectableElement

signal user_selected

@export var user_name: String

func _ready() -> void:
	super()
	(%NameLabel as Label).text = user_name
	
func _on_selected() -> void:
	pass
