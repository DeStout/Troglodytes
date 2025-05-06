extends MarginContainer


@export var lobby_code : Label
@export var player_labels : Array[Label]
@export var start_button : Button
@export var ready_button : Button


func _ready() -> void:
	ENetNetwork.lobby_code_set.connect(set_lobby_code)
	ENetNetwork.peers_updated.connect(update_peers)
	ENetNetwork.peers_ready.connect(enable_start)


func set_lobby_code(new_lobby_code : String) -> void:
	lobby_code.text = "Lobby Code: %s" % new_lobby_code


func update_peers() -> void:
	var peers : Dictionary = ENetNetwork.peers
	var peer_keys = peers.keys()
	for i in range(player_labels.size()):
		var player_label = player_labels[i]
		player_label.visible = (i+1 <= peers.size())
		if !player_label.visible:
			continue
		player_label.text = "Player %s: - %s" % [(i+1), str(peers[peer_keys[i]]["is_ready"])]


func _ready_toggled(toggled : bool) -> void:
	ENetNetwork.set_ready(toggled)


func enable_start(enabled : bool) -> void:
	start_button.disabled = !enabled


func reset() -> void:
	start_button.disabled = true
	ready_button.button_pressed = false
