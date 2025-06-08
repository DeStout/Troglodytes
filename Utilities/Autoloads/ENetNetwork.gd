extends Node


signal upnp_finished
signal server_joined
signal connection_failed
signal server_disconnected
signal peers_updated
signal peers_ready
signal peer_disconnected

const TEST_IP := "127.0.0.1"
const DEFAULT_PORT := 34500
const MAX_PEERS := 3

var peer : MultiplayerPeer
var peer_id : int = 1
var peers : Dictionary[int, Dictionary] = {}
var ping : int

var upnp_thread : Thread
var game : Game


func _ready() -> void:
	upnp_finished.connect(_close_upnp_thread)
	#upnp_thread = Thread.new()
	#upnp_thread.start(_set_up_upnp)

	# These two signal to clients only
	#multiplayer.peer_connected.connect(_peer_connected)
	#multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	multiplayer.connected_to_server.connect(_server_joined)
	multiplayer.connection_failed.connect(_connect_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)


func _set_up_upnp() -> void:
	var upnp := UPNP.new()
	var upnp_result : UPNP.UPNPResult = upnp.discover()
	print("ENetNetwork - UPNP Result: %s" % upnp_result)
	if !upnp_result:
		upnp.add_port_mapping(DEFAULT_PORT)
	upnp_finished.emit.call_deferred()


func _close_upnp_thread() -> void:
	upnp_thread.wait_to_finish()


func create_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var response : Error = peer.create_server(DEFAULT_PORT, MAX_PEERS)
	if response:
		push_error("ENetNetwork - Server creation error: %s" % response)
		connection_failed.emit()
		return
	print("ENetNetwork - Server Created: %s" % response)
	
	multiplayer.multiplayer_peer = peer
	# These two signal to the server only
	peer.peer_connected.connect(_peer_connected)
	peer.peer_disconnected.connect(_peer_disconnected)
	peer_id = 1
	peers[peer_id] = {"name" : "Player 1", "is_ready" : true}
	server_joined.emit(true, true)
	
	Debug.ping_label.visible = true


func join_server(join_address : String) -> void:
	peer = ENetMultiplayerPeer.new()
	var response : Error = peer.create_client(join_address, DEFAULT_PORT)
	if response:
		push_error("ENetNetwork - Server join error: %s" % response)
		connection_failed.emit()
		return
	
	multiplayer.multiplayer_peer = peer
	peer_id = peer.get_unique_id()
	print("Client %s - Server Join Request (%s:%s): %s" % \
									[peer_id, join_address, DEFAULT_PORT, response])


func _server_joined() -> void:
	var enet_peer = peer.get_peer(1)
	print("Remote Address: %s" % enet_peer.get_remote_address())
	server_joined.emit(true, false)
	
	Debug.ping_label.visible = true


func get_player_number() -> int:
	return peers.keys().find(multiplayer.get_unique_id())


func get_ping() -> float:
	if multiplayer.is_server():
		return 0.0
	var server : ENetPacketPeer = peer.get_peer(1)
	server.ping()
	return server.get_statistic(ENetPacketPeer.PeerStatistic.PEER_LAST_ROUND_TRIP_TIME)


func _connect_failed() -> void:
	print("Connection Failed")
	connection_failed.emit()
	reset_peer()


func _server_disconnected() -> void:
	print("%s: Server Disconnected" % peer_id)
	server_disconnected.emit()


func _peer_connected(new_peer_id : int) -> void:
	if multiplayer.is_server():
		print("Server - Peer Connected: %s" % new_peer_id)
		var new_name := "Player %s" % (peers.size()+1)
		peers[new_peer_id] = {"name" : new_name, "is_ready" : false}
		update_peers.rpc(peers)
		_check_peers_ready()


func add_local_peer() -> void:
	peer_id = 1
	peers[peer_id] = {"is_ready" : true}


func _peer_disconnected(dead_peer_id : int) -> void:
	if multiplayer.is_server():
		print("Server - Peer Disconnected: %s" % dead_peer_id)
		peers.erase(dead_peer_id)
		
		if !game.level:
			update_peers.rpc(peers)
			_check_peers_ready()
		peer_disconnected.emit(dead_peer_id)


@rpc("any_peer", "call_local")
func set_peer_name(new_name : String) -> void:
	peers[multiplayer.get_remote_sender_id()]["name"] = new_name
	update_peers.rpc(peers)


@rpc("any_peer", "call_local")
func set_peer_ready(is_ready) -> void:
	peers[multiplayer.get_remote_sender_id()]["is_ready"] = is_ready
	update_peers.rpc(peers)
	_check_peers_ready()


@rpc("call_local", "reliable")
func update_peers(new_peers : Dictionary) -> void:
	peers = new_peers
	#print("Client %s - Peers Updated: %s" % [peer_id, peers])
	peers_updated.emit()


func _check_peers_ready() -> void:
	for peer in peers:
		if !peers[peer]["is_ready"]:
			peers_ready.emit(false)
			return
		peers_ready.emit(true)


@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	multiplayer.refuse_new_connections = true
	print("%s - Starting Game" % peer_id)
	game.start_game()


@rpc("authority", "call_local", "reliable")
func quit_game() -> void:
	if multiplayer.is_server():
		update_peers.rpc(peers)
	multiplayer.refuse_new_connections = false
	game.quit_to_lobby()


func reset_peer() -> void:
	print("%s - Peer Reset: %s" % [SetWindowPos.name, peer_id])
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer = null
	peer_id = 1
	peers = {}
