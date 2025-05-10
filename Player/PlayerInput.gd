extends Node


signal input_update

var player_input : Dictionary[String, Variant] = {"dir_input" : Vector2i.ZERO,
												"attack_input" : false}


func _input(event : InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		var dir_input = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") as Vector2i
		var attack_input = Input.is_action_just_pressed("Attack")
		if player_input["dir_input"] == dir_input and \
									player_input["attack_input"] == attack_input:
			return
		player_input = {"dir_input": dir_input, "attack_input": attack_input}
		input_update.emit(player_input)
		player_input["attack_input"] = false
