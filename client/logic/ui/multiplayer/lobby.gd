extends Menu

@export var lobby_container: VBoxContainer
@export var start_button: GameButton
@export var user_element_scene: PackedScene

var _multiplayer: GlobalMultiplayer = Multiplayer
var _global: GlobalGlobal = Global


func _ready() -> void:
	pass


func _on_visibility_changed() -> void:
	if visible:
		_create_game.call_deferred()
	else:
		_remove_game.call_deferred()


func _create_game() -> void:
	if _multiplayer.client_role == _multiplayer.ClientRole.HOST:
		var match_id: String = await _multiplayer.nakama_create_match()
		if len(match_id) > 0:
			_multiplayer.nakama_join_match(match_id)
		else:
			# TODO cancel creating match after getting error
			pass
		start_button.show()
		start_button.disabled = true
	else:
		start_button.hide()
	_multiplayer.nakama_presence_changed.connect(_update_player_list)
	_multiplayer.match_started.connect(_on_match_started)


func _remove_game() -> void:
	_multiplayer.nakama_presence_changed.disconnect(_update_player_list)
	_multiplayer.match_started.disconnect(_on_match_started)


func _update_player_list() -> void:
	if len(_multiplayer.presences) > 1:
		start_button.disabled = false
	# clear last items
	for c: Node in lobby_container.get_children():
		c.queue_free()
	for presence: String in _multiplayer.presences:
		var user_id: String = _multiplayer.presences[presence].user_id
		var user_element: UserSelectableElement = user_element_scene.instantiate()
		user_element.user_name = await _multiplayer.nakama_get_username(user_id)
		user_element.deactivated = true
		lobby_container.add_child(user_element)


func _on_button_back_pressed() -> void:
	_multiplayer.nakama_disconnect_from_match()


func _on_button_start_pressed() -> void:
	randomize()
	var rand_seed: int = randi()
	var data: String = JSON.stringify({"seed": rand_seed})
	_multiplayer.nakama_send_match_state(_multiplayer.OpCodes.MATCH_START, data)


func _on_match_started() -> void:
	get_tree().change_scene_to_packed(_global.game_scene)
