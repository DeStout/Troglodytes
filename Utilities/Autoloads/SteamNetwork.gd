extends Node


signal connection_successful
signal connection_failed
signal server_disconnected
signal peer_connected
signal peer_disconnected
signal peers_updated

const DEFAULT_PORT := 36963
const MAX_PEERS := 4
const AWAIT_PEERS_TIME := 10.0
const CHECK_PEERS_TIME := 0.25
const MAX_CON_ATTEMPTS := 5

var steam_init : Dictionary
var steam_id : int
var steam_username : String

var peers : Dictionary[int, Dictionary] = {}
var peer : SteamMultiplayerPeer
var peer_id : int
var connection_attemps := 0

var lobby_id : int
var lobby_name : String



func _ready() -> void:
	return
	_reorder_peers()
	var init_attempts := 5
	for i in range(init_attempts):
		var init_success := initialize_steam()
		if init_success:
			break
		elif i < init_attempts-1:
			push_warning("Steam failed to initialize after %s attempt(s)" % (i+1))
		else:
			push_error("Steam failed to initialize - closing game")
			get_tree().quit()
	
	Steam.lobby_joined.connect(_lobby_joined)
	Steam.network_messages_session_failed.connect(_steam_session_failed)
	Steam.persona_state_change.connect(_persona_state_change)
	
	# Can't tell if these are working
	multiplayer.connected_to_server
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.peer_connected
	multiplayer.peer_disconnected
	multiplayer.server_disconnected
	
	# This doesn't seem to work correctly
	#Steam.lobby_created.connect(_lobby_created)


func _process(delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> bool:
	if steam_init:
		push_warning("Steam already initialized")
		return true
		
	steam_init = Steam.steamInitEx(480)
	print("Steam Initialization: %s" % steam_init)
	if steam_init["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		push_error("Failed to initialize Steam - ", steam_init["status"])
		steam_init = {}
		return false
	
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print(steam_username, " - ", steam_id)
	return true


func create_lobby() -> void:
	peer = SteamMultiplayerPeer.new()
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, MAX_PEERS)
	multiplayer.multiplayer_peer = peer
	peer_id = peer.get_unique_id()
	peers[peer_id] = {}
	peers[peer_id]["steam_id"] = steam_id
	peers[peer_id]["steam_name"] = steam_username
	peers[peer_id]["player_num"] = peers.size()
	print("%s - Player number: %s" % [peer_id, peers[peer_id]["player_num"]])
	_connect_signals()


func join_lobby(new_lobby_id : int) -> void:
	lobby_id = new_lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(new_lobby_id)
	multiplayer.multiplayer_peer = peer
	peer_id = peer.get_unique_id()
	_connect_signals()


func _connect_signals() -> void:
	peer.lobby_created.connect(_lobby_created)
	# This doesn't seem to work with Steam
	peer.lobby_joined.connect(_lobby_joined)
	peer.peer_connected.connect(_peer_connected)
	peer.peer_disconnected.connect(_peer_disconnected)
	peer.network_session_failed.connect(_session_failed)
	peer.debug_data.connect(Debug.network_debug_data)
	


func _disconnect_signals() -> void:
	peer.lobby_created.disconnect(_lobby_created)
	peer.lobby_joined.disconnect(_lobby_joined)
	peer.peer_connected.disconnect(_peer_connected)
	peer.peer_disconnected.disconnect(_peer_disconnected)
	peer.network_session_failed.connect(_session_failed)
	peer.debug_data.disconnect(Debug.network_debug_data)


# Called by Steam.network_messages_session_failed signal
func _steam_session_failed(reason: int, remote_steam_id: int, \
							connection_state: int, debug_message: String) -> void:
	print("\n~~ Steam Session Failed ~~\nReason: %s\nRemote Steam ID: %s\n",
									"Connection State: %s\nDebug Message: %s\n" \
					% [reason, remote_steam_id, connection_state, debug_message])


func _lobby_created(status : int, new_lobby_id : int) -> void:
	if status == Steam.RESULT_OK:
		lobby_id = new_lobby_id
		lobby_name = "%s's Lobby" % steam_username
		Steam.setLobbyData(lobby_id, "Game", "Troglodytes")
		Steam.setLobbyData(lobby_id, "Name", lobby_name)
		print("New Lobby: %s (%s) - Status: %s" % [lobby_name, lobby_id, status])
		var relay = Steam.allowP2PPacketRelay(true)
		#print("Relay set: %s" % relay)
		connection_successful.emit()
	else:
		push_error("Server creation failed - %s" % status)
		connection_failed.emit()


func _lobby_joined(lobby: int, permissions: int, locked: bool, response: int) -> void:
	#print("Lobby: %s\nPermissions: %s\nLocked: %s\nResponse: %s\n" % \
											#[lobby, permissions, locked, response])
	if response == Steam.RESULT_OK and !locked:
		lobby_id = lobby
		lobby_name = Steam.getLobbyData(lobby_id, "Name")
		print("Lobby Joined: %s (%s)" % [lobby_name, lobby_id])
		connection_successful.emit()
	else:
		connection_failed.emit()


# Called by MultiplayerAPI.connection_failed
func _connection_failed() -> void:
	print("Network (MultiplayerAPI) - Server Connection Failed % " % peer_id)
	_disconnect_signals()
	connection_failed.emit()


# Reason - https://partner.steamgames.com/doc/api/steamnetworkingtypes#ESteamNetConnectionEnd
# State -  https://partner.steamgames.com/doc/api/steamnetworkingtypes#ESteamNetworkingConnectionState
# Called by SteamPeer.network_session_failed signal
func _session_failed(steam_id: int, reason: int, connection_state: int) -> void:
	print("Network (SteamPeer) - Server Connection Failed % " % peer_id)
	if connection_attemps < MAX_CON_ATTEMPTS:
		peer.connect_lobby(lobby_id)
		connection_attemps += 1
		return
	_disconnect_signals()
	server_disconnected.emit()


func _server_disconnected() -> void:
	print("Network - Server Disconnected")
	_disconnect_signals()
	server_disconnected.emit()


func _peer_connected(new_peer_id : int) -> void:
	#await get_tree().create_timer(2.0).timeout
	print("Network - Peer Connected: %s" % new_peer_id)
	if multiplayer.is_server():
		peers[new_peer_id] = {}
		peers[new_peer_id]["steam_id"] = peer.get_steam64_from_peer_id(new_peer_id)
		peers[new_peer_id]["steam_name"] = ""
		peers[new_peer_id]["player_num"] = peers.size()
		if !Steam.requestUserInformation(new_peer_id, false):
			var new_steam_name = \
						Steam.getFriendPersonaName(peers[new_peer_id]["steam_id"])
			peers[new_peer_id]["steam_name"] = new_steam_name
		_reorder_peers()
		peers_updated.emit()
	else:
		_await_new_peers()


func _peer_disconnected(dead_peer_id : int) -> void:
	print("Network - Peer Disconnected: %s" % dead_peer_id)
	if dead_peer_id == 1:
		_server_disconnected()
		
	if multiplayer.is_server():
		peers.erase(dead_peer_id)
		_reorder_peers()
		peers_updated.emit()
	else:
		_await_new_peers()


func _reorder_peers() -> void:
	#var peers := {1: {"steam_id": 1, "steam_name": "blah1", "player_num": 1},
					#3452345345: {"steam_id": 567456756475674567, "steam_name": "blah2", "player_num": 4}}
	var temp_peers : Dictionary[int, int] = {}
	for i in range(1, peers.size()):
		temp_peers[peers[peers.keys()[i]]["player_num"]] = peers.keys()[i]
	temp_peers.sort()
	for i in range(temp_peers.keys().size()):
		peers[temp_peers[temp_peers.keys()[i]]]["player_num"] = i+2


func _await_new_peers() -> void:
		var temp_peers = peers
		var break_timer = get_tree().create_timer(AWAIT_PEERS_TIME)
		while temp_peers == peers:
			request_peers.rpc_id(1)
			await get_tree().create_timer(CHECK_PEERS_TIME).timeout
			if !break_timer.time_left:
				push_error("Set peers time exceded - Peers out of date")
				break
		print("Set peers loop broken")


@rpc("any_peer", "call_remote")
func request_peers() -> void:
	if multiplayer.is_server():
		_set_peers.rpc_id(multiplayer.get_remote_sender_id(), peers)


@rpc("call_remote", "reliable")
func _set_peers(new_peers : Dictionary) -> void:
	peers = new_peers
	peers_updated.emit()


# flags PersonaChange:
	# ● PERSONA_CHANGE_NAME = 1
	# ● PERSONA_CHANGE_STATUS = 2
	# ● PERSONA_CHANGE_COME_ONLINE = 4
	# ● PERSONA_CHANGE_GONE_OFFLINE = 8
	# ● PERSONA_CHANGE_GAME_PLAYED = 16
	# ● PERSONA_CHANGE_GAME_SERVER = 32
	# ● PERSONA_CHANGE_AVATAR = 64
	# ● PERSONA_CHANGE_JOINED_SOURCE = 128
	# ● PERSONA_CHANGE_LEFT_SOURCE = 256
	# ● PERSONA_CHANGE_RELATIONSHIP_CHANGED = 512
	# ● PERSONA_CHANGE_NAME_FIRST_SET = 1024
	# ● PERSONA_CHANGE_FACEBOOK_INFO = 2048
	# ● PERSONA_CHANGE_NICKNAME = 4096
	# ● PERSONA_CHANGE_STEAM_LEVEL = 8192
	# ● PERSONA_CHANGE_RICH_PRESENCE = 16384
func _persona_state_change(p_steam_id : int, flag : int) -> void:
	if !peer:
		push_warning("No local peer created. Returning.")
		return
	var p_id := peer.get_peer_id_from_steam64(p_steam_id)
	if p_id == -1:
		push_warning("%s - Steam ID not a peer. Returning." % p_steam_id)
		return
	print("Persona State Change (%s) - %s" % [p_steam_id, flag])
	
	_check_peer_names()
	_check_peer_avatars()


func _check_peer_names() -> void:
	#print("Checking peer names")
	for pid in peers:
		var steam_name := Steam.getFriendPersonaName(peers[pid]["steam_id"])
		if peers[pid]["steam_name"] != steam_name:
			peers[pid]["steam_name"] = steam_name
			peers_updated.emit()


func _check_peer_avatars() -> void:
	pass


func reset_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer = null
	peer_id = -1
	peers = {}
	lobby_id = -1
	lobby_name = ""
