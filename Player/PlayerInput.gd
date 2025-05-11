extends MultiplayerSynchronizer


signal input_update

var player_input : Dictionary[String, Variant] = {"dir_input" : Vector2.ZERO, 
															"attack_input" : false}


func _ready() -> void:
	public_visibility = false
	set_visibility_for(1, true)


func _input(event : InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventKey or event is InputEventMouseButton:
		var dir_input = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
		var attack_input = Input.is_action_just_pressed("Attack")
		if player_input["dir_input"] == dir_input and \
									player_input["attack_input"] == attack_input:
			return
		player_input = {"dir_input": dir_input, "attack_input": attack_input}
		
		if multiplayer.is_server():
			_input_updated()


func _input_updated() -> void:
	if !multiplayer.is_server():
		return
	if !player_input["dir_input"] and !player_input["attack_input"]:
		return
	input_update.emit(player_input)
	player_input["attack_input"] = false


func get_player_input() -> Dictionary:
	return player_input
