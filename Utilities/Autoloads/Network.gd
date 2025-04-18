extends Node


signal connection_successful
signal connection_failed

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
	
	multiplayer.connected_to_server
	multiplayer.connection_failed
	multiplayer.server_disconnected
	multiplayer.peer_connected
	multiplayer.peer_disconnected
	Steam.lobby_created.connect(_lobby_created)
	Steam.lobby_joined


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
	peer = SteamMultiplayerPeer.new()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print(steam_username, " - ", steam_id)
	return true


func shutdown_steam() -> void:
	print("Steam shutdown")
	set_process(false)
	steam_init = {}
	peer = null
	steam_id = -1
	steam_username = ""
	Steam.steamShutdown()


func create_lobby() -> void:
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_PEERS)


func _lobby_created(status : int, new_lobby_id : int) -> void:
	if status == Steam.RESULT_OK:
		lobby_id = new_lobby_id
		lobby_name = "%s's Lobby" % steam_username
		Steam.setLobbyData(lobby_id, "Game", "Troglodytes")
		Steam.setLobbyData(lobby_id, "Name", lobby_name)
		print("New Lobby (%s) - %s" % [lobby_id, status])
		var relay = Steam.allowP2PPacketRelay(true)
		print("Steam relay back up - %s" % relay)
		connection_successful.emit()
	else:
		push_error("Server creation failed - %s" % status)
		connection_failed.emit()
