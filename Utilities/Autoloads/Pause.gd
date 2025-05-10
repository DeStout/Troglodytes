extends Control


@export var options : Control


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if !Globals.game is Game or !Globals.game.level:
		return
	if Input.is_action_just_pressed("Pause"):
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
