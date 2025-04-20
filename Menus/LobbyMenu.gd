extends MarginContainer


@export var lobby_name : Label
@export var player_names : Array[Label]


func _ready() -> void:
	Network.peers_updated.connect(update_players)
	Network.peer_disconnected.connect(remove_dead_peer)


func set_up() -> void:
	lobby_name.text = Network.lobby_name
	if multiplayer.is_server():
		player_names[0].text = "Player 1: " + Network.steam_username


func remove_dead_peer(dead_peer_player_num : int) -> void:
	print("Lobby - Dead Peer Player number %s" % dead_peer_player_num)
	player_names[dead_peer_player_num-1].text = "Player %s" % dead_peer_player_num


func update_players() -> void:
	var peers = Network.peers
	for i in range(1, 5):
		player_names[i-1].text = "Player %s:" % i
	for peer in peers:
		var player_num : int = peers[peer]["player_num"]
		var player_name : String = peers[peer]["steam_name"]
		player_names[player_num-1].text = "Player %s: %s" % [player_num, player_name]


func reset() -> void:
	for i in range(1, 5):
		player_names[i-1].text = "Player %s:" % i
