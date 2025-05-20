extends Control


var game : Game
@export var options : Control


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if !game is Game or !game.level:
		return
	if Input.is_action_just_pressed("Pause"):
		_pause()


func _pause() -> void:
		if !ENetNetwork.peers.size() > 1:
			get_tree().paused = !get_tree().paused
		visible = !visible
		
		match visible:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			false:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func update() -> void:
	options.update()


func _quit() -> void:
	if !game:
		get_tree().quit()
		return
	
	if multiplayer.is_server():
		ENetNetwork.quit_game.rpc()
		return
	
	game.quit_to_main()
