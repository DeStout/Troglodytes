extends Control


@export var options : Control


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if !Globals.game is Game or !Globals.game.level:
		return
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused
		
		match get_tree().paused:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			false:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func update() -> void:
	options.update()
