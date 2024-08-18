class_name LobbySelectableElement
extends SelectableElement

signal lobby_selected(element: LobbySelectableElement)

@export var title: String
@export var map_name: String
@export var match_id: String

@onready var title_label: Label = $Element/TitleLabel
@onready var map_label: Label = $Element/MapLabel
@onready var select_overlay: ColorRect = $SelectOverlay


func _ready() -> void:
	super()
	select_overlay.hide()
	title_label.text = title
	map_label.text = map_name


func _on_selected() -> void:
	lobby_selected.emit(self)
