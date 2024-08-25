class_name GlobalMultiplayer
extends Node

signal nakama_connected
signal nakama_presence_changed
signal match_started

enum ClientRole { NONE, CLIENT, HOST }

enum OpCodes {
	MESSAGE,
	MATCH_START,
	STATE_CHANGE,
	EVENT_CHANGE,
	FSM_ROUND,
}

const CONFIG_FILE_PATH: String = "user://network.cfg"
const CONFIG_DEVICE_SECTION: String = "device"

var nakama_client: NakamaClient
var nakama_session: NakamaSession
var nakama_socket: NakamaSocket
var nakama_match: NakamaAPI.ApiRpc

var client_role: ClientRole = ClientRole.NONE
var own_user_id: String
var current_match_id: String
# Dictionary with user_id for keys and NakamaPresence for values.
var presences: Dictionary = {}
var network_fsm_round_queue: Array[String]
var random_seed: int


var _global: GlobalGlobal = Global


func _ready() -> void:
	pass


# Wrapper for device id. Stores the id in a file to prevent regenerated ids.
func get_device_id() -> String:
	if ProjectSettings.get_setting("global/network/debug_accounts"):
		return "DEBUG_+_" + str(OS.get_process_id())
	var network_config: ConfigFile = ConfigFile.new()
	network_config.load(CONFIG_FILE_PATH)
	if network_config.has_section_key(CONFIG_DEVICE_SECTION, "device_id"):
		return network_config.get_value(CONFIG_DEVICE_SECTION, "device_id")
	var device_id: String
	if OS.get_name() == "Web":
		device_id = str(randi()).sha256_text().left(32)
	else:
		device_id = OS.get_unique_id()
	network_config.set_value(CONFIG_DEVICE_SECTION, "device_id", device_id)
	network_config.save(CONFIG_FILE_PATH)
	return device_id


func nakama_login() -> Error:
	if not nakama_session or nakama_session.expired:
		var scheme: String
		if ProjectSettings.get_setting("global/network/https"):
			scheme = "https"
		else:
			scheme = "http"
		var host: String = ProjectSettings.get_setting("global/network/lobby_server")
		var port: int = ProjectSettings.get_setting("global/network/lobby_port")
		var server_key: String = ProjectSettings.get_setting("global/network/lobby_key")
		nakama_client = Nakama.create_client(server_key, host, port, scheme)
		var device_id: String = get_device_id()
		var vars: Dictionary = {
			"device_os": OS.get_name(),
			"device_model": OS.get_model_name(),
		}
		# Use 'await' to wait for the request to complete.
		nakama_session = await nakama_client.authenticate_device_async(device_id, null, true, vars)
		if nakama_session.is_exception():
			return ERR_CANT_CONNECT
		nakama_socket = Nakama.create_socket_from(nakama_client)
		var connected: NakamaAsyncResult = await nakama_socket.connect_async(nakama_session)
		if connected.is_exception():
			return ERR_CANT_CONNECT
		nakama_socket.received_error.connect(_on_nakama_socket_received_error)
		nakama_socket.received_match_presence.connect(_on_nakama_received_match_presence)
		nakama_socket.received_match_state.connect(_on_nakama_received_match_state)
		own_user_id = await nakama_get_user_id()
		nakama_connected.emit()
	return OK


# If no user_id is set function will return own user name
func nakama_get_username(user_id: String = "") -> String:
	if user_id:
		var users: NakamaAPI.ApiUsers = await nakama_client.get_users_async(
			nakama_session, PackedStringArray([user_id])
		)
		return users.users[0].display_name
	var account: NakamaAPI.ApiAccount = await nakama_client.get_account_async(nakama_session)
	return account.user.display_name


func nakama_get_user_id() -> String:
	var account: NakamaAPI.ApiAccount = await nakama_client.get_account_async(nakama_session)
	return account.user.id


func nakama_set_username(user_name: String) -> void:
	var _update: NakamaAsyncResult = await nakama_client.update_account_async(
		nakama_session, null, user_name
	)


func nakama_log_out() -> void:
	if nakama_client:
		await nakama_client.session_logout_async(nakama_session)
		nakama_match = null
		nakama_socket = null
		nakama_session = null
		nakama_client = null
		client_role = ClientRole.NONE


func nakama_check_and_refresh_session() -> void:
	if nakama_session.expired:
		nakama_session = await nakama_client.session_refresh_async(nakama_session)


func nakama_create_match() -> String:
	if not _global.selected_map_json:
		printerr("Error while creating multiplayer match: No map selected")
		return ""
	var nick_name: String = await nakama_get_username()
	var map_json: String = _global.selected_map_json
	var map: Map = MapFile.deserialize(map_json)
	var map_name: String = map.map_name
	map.queue_free()
	var data: Dictionary = {
		match_name = "%s" % nick_name,
		map_name = map_name,
	}
	nakama_match = await nakama_client.rpc_async(
		nakama_session, "create_match_rpc", JSON.stringify(data)
	)
	presences = {}
	var payload: String = nakama_match["payload"]
	return JSON.parse_string(payload)["matchid"]


func nakama_join_match(match_id: String) -> void:
	presences = {}
	var match_join_result: NakamaRTAPI.Match = await nakama_socket.join_match_async(match_id)
	for presence: NakamaRTAPI.UserPresence in match_join_result.presences:
		presences[presence.user_id] = presence
	current_match_id = match_id


func nakama_send_match_state(op_code: int, message: String) -> void:
	await nakama_socket.send_match_state_async(current_match_id, op_code, message)


func nakama_disconnect_from_match() -> void:
	nakama_socket.leave_match_async(current_match_id)


func nakama_get_matches_list() -> NakamaAPI.ApiMatchList:
	var player_min: int = 0
	var player_max: int = 100
	var player_limit: int = 100
	var authoritative: bool = true
	var label: String = ""
	var query: String = ""
	return await nakama_client.list_matches_async(
		nakama_session, player_min, player_max, player_limit, authoritative, label, query
	)


func _on_nakama_socket_received_error() -> void:
	pass


func _on_nakama_received_match_presence(new_presences: NakamaRTAPI.MatchPresenceEvent) -> void:
	for leave: NakamaRTAPI.UserPresence in new_presences.leaves:
		presences.erase(leave.user_id)
	for join: NakamaRTAPI.UserPresence in new_presences.joins:
		presences[join.user_id] = join
	nakama_presence_changed.emit()


func _on_nakama_received_match_state(match_state: NakamaRTAPI.MatchData) -> void:
	if match_state.op_code == OpCodes.MATCH_START:
		random_seed = JSON.parse_string(match_state.data)["seed"]
		_global.game_mode = GameConst.GameMode.NETWORK
		match_started.emit()
	if match_state.op_code == OpCodes.FSM_ROUND:
		if match_state.data:
			network_fsm_round_queue.append(match_state.data)
			print_debug(
				GameConst.State.keys()[JSON.parse_string(match_state.data)["network_state"]]
			)
			print_debug(
				GameConst.Event.keys()[JSON.parse_string(match_state.data)["network_event"]]
			)
