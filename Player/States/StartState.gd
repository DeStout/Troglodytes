class_name StartState extends State


const START_TIME := 1.0

@onready var start_timer := $StartTimer


func enter() -> void:
	#print("Enter StartState")
	start_timer.start(START_TIME)
	character.set_invincible(character.START_INV_TIME)
	character.anim_player.speed_scale = 1.0
	character.anim_player.play("Idle")
	character._footstep(true)
	character._footstep(false)


# called from start_timer.timeout
func _start_finished() -> void:
	print("move")
	transition.emit(self, "MoveState")


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey:
		if _is_direction_pressed(event):
			if character.ray_check(_get_input_dir(event)):
				return
			_set_move_dir(event)


func _is_direction_pressed(event : InputEvent) -> bool:
	if event.is_action_pressed("MoveUp") or event.is_action_pressed("MoveDown") or \
										event.is_action_pressed("MoveLeft") or \
										event.is_action_pressed("MoveRight"):
		return true
	return false


func _get_input_dir(event : InputEventKey) -> int:
	if event.is_action_pressed("MoveUp"):
		return Utilities.DIRECTIONS.UP
	if event.is_action_pressed("MoveDown"):
		return Utilities.DIRECTIONS.DOWN
	if event.is_action_pressed("MoveLeft"):
		return Utilities.DIRECTIONS.LEFT
	if event.is_action_pressed("MoveRight"):
		return Utilities.DIRECTIONS.RIGHT
	return -1


func _set_move_dir(event : InputEvent):
	if event.is_action_pressed("MoveUp"):
		character.move_dir = Utilities.DIRECTIONS.UP
	elif event.is_action_pressed("MoveDown"):
		character.move_dir = Utilities.DIRECTIONS.DOWN
	elif event.is_action_pressed("MoveLeft"):
		character.move_dir = Utilities.DIRECTIONS.LEFT
	elif event.is_action_pressed("MoveRight"):
		character.move_dir = Utilities.DIRECTIONS.RIGHT


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
