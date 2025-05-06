extends Node


signal upnp_finished
signal server_joined
signal lobby_code_set
signal connection_failed
signal server_disconnected
signal peers_updated
signal peers_ready

const TEST_IP := "127.0.0.1"
const DEFAULT_PORT := 36963
const MAX_PEERS := 3

var lobby_code : String
var peer : MultiplayerPeer
var peer_id : int
var peers : Dictionary[int, Dictionary] = {}

var upnp_thread : Thread


func _ready() -> void:
	upnp_finished.connect(_close_upnp_thread)
	upnp_thread = Thread.new()
	upnp_thread.start(_set_up_upnp)

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
	peers[peer_id] = {"is_ready" : true}
	
	print("Server - Lobby Code: %s" % lobby_code)
	server_joined.emit(true, true)


func join_server(join_address : String) -> void:
	var ip : String = Utilities.decode_ip(join_address)
	var port := DEFAULT_PORT
	if ip == "Invalid" or ip == join_address:
		push_warning("ENetNetwork - %s not coded ip, trying uncoded" % join_address)
		var ip_port := join_address.split(":")
		ip = ip_port[0]
		if ip_port.size() > 1:
			port = int(ip_port[1])
		if !ip.is_valid_ip_address():
			push_error("ENetNetwork - Invalid IP Address, returning")
			connection_failed.emit()
			return
			
	#ip = TEST_IP
	peer = ENetMultiplayerPeer.new()
	var response : Error = peer.create_client(ip, port)
	if response:
		push_error("ENetNetwork - Server join error: %s" % response)
		connection_failed.emit()
		return
	
	multiplayer.multiplayer_peer = peer
	peer_id = peer.get_unique_id()
	print("Client %s - Server Join Request (%s:%s): %s" % [peer_id, ip, port, response])


func _server_joined() -> void:
	var enet_peer = peer.get_peer(1)
	print("Remote Address: %s" % enet_peer.get_remote_address())
	server_joined.emit(true, false)


func _connect_failed() -> void:
	print("Connection Failed")
	connection_failed.emit()
	reset_peer()


func _server_disconnected() -> void:
	print("Server Disconnected")
	server_disconnected.emit()


func _peer_connected(new_peer_id : int) -> void:
	if multiplayer.is_server():
		set_lobby_code.rpc_id(new_peer_id, lobby_code)
		print("Server - Peer Connected: %s" % new_peer_id)
		peers[new_peer_id] = {"is_ready" : false}
		update_peers.rpc(peers)
		_check_peers_ready()


func _peer_disconnected(dead_peer_id : int) -> void:
	if multiplayer.is_server():
		print("Server - Peer Disconnected: %s" % dead_peer_id)
		peers.erase(dead_peer_id)
		update_peers.rpc(peers)
		_check_peers_ready()


@rpc("authority", "call_remote")
func set_lobby_code(new_lobby_code : String) -> void:
	lobby_code = new_lobby_code
	lobby_code_set.emit(lobby_code)


func set_ready(is_ready : bool) -> void:
	peer_set_ready.rpc_id(1, is_ready)


@rpc("any_peer", "call_remote")
func peer_set_ready(is_ready) -> void:
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


func reset_peer() -> void:
	if multiplayer.is_server():
		print("Server - Peer Reset")
	else:
		print("Clinet %s - Peer Reset" % [peer_id])
	peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer_id = 0
	peers = {}
