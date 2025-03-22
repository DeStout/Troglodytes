class_name IdleState extends State


func enter() -> void:
	#print("Enter IdleState")
	pass


func exit() -> void:
	pass


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey:
		if _is_direction_pressed(event):
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


func update(delta) -> void:
	pass


func physics_update(delta) -> void:
	pass


func _set_move_dir(event : InputEvent):
	if event.is_action_pressed("MoveUp"):
		character.move_dir = character.DIRECTIONS.UP
	elif event.is_action_pressed("MoveDown"):
		character.move_dir = character.DIRECTIONS.DOWN
	elif event.is_action_pressed("MoveLeft"):
		character.move_dir = character.DIRECTIONS.LEFT
	elif event.is_action_pressed("MoveRight"):
		character.move_dir = character.DIRECTIONS.RIGHT


func respawn() -> void:
	pass
