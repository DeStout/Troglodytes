extends Node


signal connection_successful
signal connection_failed
signal server_disconnected

const DEFAULT_PORT := 36963
const MAX_PEERS := 4

var peer : SteamMultiplayerPeer

var steam_init : Dictionary
var steam_id : int
var steam_username : String

var lobby_id : int
var lobby_name : String

var players : Array[Dictionary]


func _ready() -> void:
	set_process(false)
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	# Can't tell if this is working
	multiplayer.server_disconnected.connect(_server_disconnected)
	# This doesn't seem to work correctly
	#Steam.lobby_created.connect(_lobby_created)
	Steam.lobby_joined.connect(_lobby_joined)
	Steam.network_messages_session_failed.connect(_session_failed)


func _process(delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> bool:
	if steam_init:
		push_warning("Steam already initialized")
		return true
		
	steam_init = Steam.steamInitEx(480, true)
	print("Steam Initialization: %s" % steam_init)
	if steam_init["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		push_error("Failed to initialize Steam - ", steam_init["status"])
		steam_init = {}
		return false
	
	set_process(true)
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print(steam_username, " - ", steam_id)
	return true


func create_lobby() -> void:
	peer = SteamMultiplayerPeer.new()
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, MAX_PEERS)
	multiplayer.multiplayer_peer = peer
	_connect_signals()


func join_lobby(lobby_id : int) -> void:
	peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	_connect_signals()


func _connect_signals() -> void:
	peer.lobby_created.connect(_lobby_created)
	# This doesn't seem to work correctly
	#peer.lobby_joined.connect(_lobby_joined)
	peer.peer_connected.connect(_peer_connected)
	peer.peer_disconnected.connect(_peer_disconnected)


func _disconnect_signals() -> void:
	peer.lobby_created.disconnect(_lobby_created)
	#peer.lobby_joined.disconnect(_lobby_joined)
	peer.peer_connected.disconnect(_peer_connected)
	peer.peer_disconnected.disconnect(_peer_disconnected)


func _session_failed(reason: int, remote_steam_id: int, \
							connection_state: int, debug_message: String) -> void:
	print("\n~~ Session Failed ~~\nReason: %s\nRemote Steam ID: %s\nConnection State: %s\nDebug Message: %s\n" \
						% [reason, remote_steam_id, connection_state, debug_message])


func _lobby_created(status : int, new_lobby_id : int) -> void:
	if status == Steam.RESULT_OK:
		lobby_id = new_lobby_id
		lobby_name = "%s's Lobby" % steam_username
		print("Lobby name: %s" % lobby_name)
		Steam.setLobbyData(lobby_id, "Game", "Troglodytes")
		Steam.setLobbyData(lobby_id, "Name", lobby_name)
		print("New Lobby (%s) - %s" % [lobby_id, status])
		var relay = Steam.allowP2PPacketRelay(true)
		print("Steam relay back up - %s" % relay)
		connection_successful.emit()
	else:
		push_error("Server creation failed - %s" % status)
		connection_failed.emit()


func _lobby_joined(lobby: int, permissions: int, locked: bool, response: int) -> void:
	print("Lobby: %s\nPermissions: %s\nLocked: %s\nResponse: %s\n" % \
											[lobby, permissions, locked, response])
	if response == Steam.RESULT_OK and !locked:
		lobby_id = lobby
		connection_successful.emit()
	else:
		connection_failed.emit()


func _connected_to_server() -> void:
	print("Network - Connected to Server")


func _connection_failed() -> void:
	print("Network - Server Connection Failed")
	_disconnect_signals()
	connection_failed.emit()


func _server_disconnected() -> void:
	print("Network - Server Disconnected")
	_disconnect_signals()
	server_disconnected.emit()


func _peer_connected(peer_id : int) -> void:
	print("Network - Peer Connected: %s" % peer_id)


func _peer_disconnected(peer_id : int) -> void:
	print("Network - Peer Disconnected: %s" % peer_id)


func shutdown_steam() -> void:
	print("Steam shutdown")
	set_process(false)
	steam_init = {}
	multiplayer.multiplayer_peer = null
	peer = null
	steam_id = -1
	steam_username = ""
	Steam.steamShutdown()
