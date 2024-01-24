extends SelectableElement
class_name LobbySelectableElement

signal lobby_selected

@export var title: String
@export var map_name: String
@export var map_path: String
@export var match_id: String

func _ready() -> void:
	super()
	($SelectOverlay as Control).hide()
	(%TitleLabel as Label).text = title
	(%MapLabel as Label).text = map_name

func _on_selected() -> void:
	lobby_selected.emit(self)
