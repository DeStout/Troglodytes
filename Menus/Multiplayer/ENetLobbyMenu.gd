extends MarginContainer


@export var name_edit : LineEdit
@export var player_names : Array[Label]
@export var players_ready : Array[Label]
@export var start_button : Button
@export var ready_button : Button


func _ready() -> void:
	ENetNetwork.peers_updated.connect(update_peers)
	ENetNetwork.peers_ready.connect(enable_start)
	
	start_button.pressed.connect(ENetNetwork.start_game.rpc)
	
	for i in range(player_names.size()):
		player_names[i].visible = false
		players_ready[i].visible = false


func update_peers() -> void:
	var peers : Dictionary = ENetNetwork.peers
	var peer_keys = peers.keys()
	for i in range(player_names.size()):
		var player_name = player_names[i]
		var player_ready = players_ready[i]
		player_name.visible = (i+1 <= peers.size())
		player_ready.visible = (i+1 <= peers.size())
		
		if i >= peers.size():
			continue
		
		player_name.text = peers[peers.keys()[i]]["name"]
		var is_ready := "Ready" if peers[peers.keys()[i]]["is_ready"] else "Waiting"
		player_ready.text = is_ready


func _name_updated(new_name : String) -> void:
	var player_num := ENetNetwork.get_player_number()
	if new_name.is_empty():
		new_name = "%s %s" % [name_edit.placeholder_text, player_num+1]
	player_names[player_num].text = new_name
	if ENetNetwork.peer:
		ENetNetwork.set_peer_name.rpc_id(1, new_name)


func _ready_toggled(toggled : bool) -> void:
	var is_ready := "Ready" if toggled else "Waiting"
	players_ready[ENetNetwork.get_player_number()].text = is_ready
	if ENetNetwork.peer:
		ENetNetwork.set_peer_ready.rpc_id(1, toggled)


func enable_start(enabled : bool) -> void:
	start_button.disabled = !enabled


func reset() -> void:
	name_edit.clear()
	start_button.disabled = true
	ready_button.button_pressed = false
