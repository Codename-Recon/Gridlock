extends Menu

@export var username_text: TextEdit
@export var lobby_list_container: VBoxContainer
@export var lobby_menu: Menu
@export var lobby_element_scene: PackedScene

var name_file_path: String = "res://assets/text/names.txt"
var username_changed_in_text_edit: bool = false

var _global: GlobalGlobal = Global
var _multiplayer: GlobalMultiplayer = Multiplayer
var _messages: GlobalMessages = Messages


func _ready() -> void:
	# block editing until server response
	username_text.editable = false


func _pick_random_username() -> String:
	var file: FileAccess = FileAccess.open(name_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	var username: String = ""
	while username == "":
		username = Array(content.split("\n")).pick_random()
	return username


func _set_username() -> void:
	var username: String = await _multiplayer.nakama_get_username()
	if username == "":
		if ProjectSettings.get_setting("global/network/debug_accounts"):
			username_text.text = "DEBUG_ACCOUNT"
		else:
			username_text.text = _pick_random_username()
		_multiplayer.nakama_set_username(username_text.text)
	else:
		username_text.text = username


func _list_lobbies() -> void:
	var result: NakamaAPI.ApiMatchList = await _multiplayer.nakama_get_matches_list()
	# clear last lobby items
	for c: Node in lobby_list_container.get_children():
		c.queue_free()
	for m: NakamaAPI.ApiMatch in result.matches:
		# only list lobby with less than 2 players (already full)
		if m.size < 2:
			print_debug("%s: %s/10 players, labels: %s " % [m.match_id, m.size, m.label])
			var labels: Dictionary = JSON.parse_string(m.label)
			var lobby_element: LobbySelectableElement = lobby_element_scene.instantiate()
			lobby_element.title = labels["match_name"]
			lobby_element.map_name = labels["map_name"]
			lobby_element.match_id = m.match_id
			lobby_element.lobby_selected.connect(_on_lobby_element_selected)
			lobby_list_container.add_child(lobby_element)


func _on_visibility_changed() -> void:
	if visible:
		var res: Error = await _multiplayer.nakama_login()
		if res > OK:
			_messages.spawn(
				tr("MESSAGE_TITLE_LOBBY_CONNECTION_PROBLEM"),
				tr("MESSAGE_TEXT_LOBBY_CONNECTION_PROBLEM"),
				true
			)
			await _messages.action_done
			return
		username_text.editable = true
		_set_username()
		_list_lobbies()


func _on_text_edit_username_text_changed() -> void:
	username_changed_in_text_edit = true


func _on_text_edit_username_focus_exited() -> void:
	if username_changed_in_text_edit:
		await _multiplayer.nakama_set_username(username_text.text)


func _on_button_refresh_pressed() -> void:
	_list_lobbies()


func _on_lobby_element_selected(element: LobbySelectableElement) -> void:
	_global.selected_map_json = _global.maps[element.map_name]
	_multiplayer.nakama_join_match(element.match_id)
	hide()
	_multiplayer.client_role = _multiplayer.ClientRole.CLIENT
	lobby_menu.show()


func _on_button_host_pressed() -> void:
	_multiplayer.client_role = _multiplayer.ClientRole.HOST
