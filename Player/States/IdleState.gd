class_name IdleState extends State


func enter() -> void:
	#print("Enter IdleState")
	if character.anim_player:
		character.anim_player.speed_scale = 1.0
		character.anim_player.play("Idle")


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey:
		if _is_direction_pressed(event):
			if character.ray_check(_get_input_dir(event)):
				return
			_set_move_dir(event)
			transition.emit(self, "MoveState")
		elif event.is_action_pressed("Attack"):
			transition.emit(self, "AttackState")


func _is_direction_pressed(event : InputEvent) -> bool:
	if event.is_action_pressed("MoveUp") or event.is_action_pressed("MoveDown") or \
										event.is_action_pressed("MoveLeft") or \
										event.is_action_pressed("MoveRight"):
		return true
	return false


func _get_input_dir(event : InputEventKey) -> int:
	if event.is_action_pressed("MoveUp"):
		return character.DIRECTIONS.UP
	if event.is_action_pressed("MoveDown"):
		return character.DIRECTIONS.DOWN
	if event.is_action_pressed("MoveLeft"):
		return character.DIRECTIONS.LEFT
	if event.is_action_pressed("MoveRight"):
		return character.DIRECTIONS.RIGHT
	return -1


func _set_move_dir(event : InputEvent):
	if event.is_action_pressed("MoveUp"):
		character.move_dir = character.DIRECTIONS.UP
	elif event.is_action_pressed("MoveDown"):
		character.move_dir = character.DIRECTIONS.DOWN
	elif event.is_action_pressed("MoveLeft"):
		character.move_dir = character.DIRECTIONS.LEFT
	elif event.is_action_pressed("MoveRight"):
		character.move_dir = character.DIRECTIONS.RIGHT


# Keep this, please
func respawn() -> void: pass


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
