class_name MoveState extends State


const SNAP_TOL := 0.007

var turning := false


func enter() -> void:
	#print("Enter MoveState")
	character.anim_player.speed_scale = character.anim_speed
	character.anim_player.play("Walk")
	if _is_turn_around():
		_turn_around()
	_set_target_square()
	await _slerp_to_dirp()


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey:
		if _is_turn_around():
			_turn_around()
			_set_target_square()
			await _slerp_to_dirp(true)
		elif event.is_action_pressed("Attack"):
			transition.emit(self, "AttackState")
	elif event is InputEventMouseButton:
		if event.is_action_pressed("Attack"):
			transition.emit(self, "AttackState")


func _is_turn_around() -> bool:
	return _is_direction_pressed() and _is_opp_dir_pressed() and _get_num_input() == 1


func _is_direction_pressed() -> bool:
	if Input.is_action_pressed("MoveUp") or Input.is_action_pressed("MoveDown") or \
										Input.is_action_pressed("MoveLeft") or \
										Input.is_action_pressed("MoveRight"):
		return true
	return false


func _is_opp_dir_pressed() -> bool:
	if character.move_dir == Utilities.DIRECTIONS.UP and \
											Input.is_action_pressed("MoveDown"):
		return true
	if character.move_dir == Utilities.DIRECTIONS.DOWN and \
											Input.is_action_pressed("MoveUp"):
		return true
	if character.move_dir == Utilities.DIRECTIONS.LEFT and \
											Input.is_action_pressed("MoveRight"):
		return true
	if character.move_dir == Utilities.DIRECTIONS.RIGHT and \
											Input.is_action_pressed("MoveLeft"):
		return true
	return false


func _turn_around() -> void:
	var char_pos := Utilities.v3_to_v2(character.global_position)
	character.velocity = Vector3.ZERO
	character.move_dir = _get_input_dir()


func physics_update(delta) -> void:
	if turning:
		return
		
	_move(delta)
	if !_is_at_target():
		return
	var walls :=[character.ray_check(character.move_dir), \
											character.ray_check(_get_input_dir())]
	if _get_num_input() == 1 and character.move_dir != _get_input_dir():
		# Turn if no wall in input direction
		if !walls[1]:
			_stop_and_snap()
			character.move_dir = _get_input_dir()
			_set_target_square()
			await _slerp_to_dirp()
			return
		# Stop if wall ahead
		if walls[0]:
			_stop_and_snap()
			return
		# Continue forward if wall in input direction
		if walls[1]:
			_set_target_square()
			
	elif walls[0]:
		_stop_and_snap()
		transition.emit(self, "IdleState")
	_set_target_square()


func _stop_and_snap() -> void:
	character.position.x = character.target_square.x
	character.position.z = character.target_square.y
	character.velocity = Vector3.ZERO


func _move(delta : float) -> void:
	var move_dir := Utilities.get_move_dir_vect(character.move_dir)
	character.velocity.x = move_toward(character.velocity.x, \
				move_dir.x * character.speed, character.ACCEL * delta)
	character.velocity.z = move_toward(character.velocity.z, \
				move_dir.y * character.speed, character.ACCEL * delta)
	character.move_and_slide()


func _is_at_target() -> bool:
	var char_pos := Utilities.v3_to_v2(character.global_position)
	if char_pos.distance_squared_to(character.target_square) < SNAP_TOL:
		return true
	return false


func _get_num_input() -> int:
	var num_input := 0
	if Input.is_action_pressed("MoveUp"):
		num_input += 1
	if Input.is_action_pressed("MoveDown"):
		num_input += 1
	if Input.is_action_pressed("MoveLeft"):
		num_input += 1
	if Input.is_action_pressed("MoveRight"):
		num_input += 1
	return num_input


func _get_input_dir() -> int:
	if Input.is_action_pressed("MoveUp"):
		return Utilities.DIRECTIONS.UP
	if Input.is_action_pressed("MoveDown"):
		return Utilities.DIRECTIONS.DOWN
	if Input.is_action_pressed("MoveLeft"):
		return Utilities.DIRECTIONS.LEFT
	if Input.is_action_pressed("MoveRight"):
		return Utilities.DIRECTIONS.RIGHT
	return -1


func _slerp_to_dirp(stop := false) -> void:
	var target_dir := Utilities.get_move_dir_vect(character.move_dir)
	# Do nothing if already facing the correct direction
	if target_dir == Utilities.v3_to_v2(-character.basis.z):
		return
	
	turning = stop
	var new_basis : Basis = character.basis.looking_at(Vector3(target_dir.x, 0, target_dir.y))
	
	var turn_dir = -character.basis.z.signed_angle_to(-new_basis.z, Vector3.UP)
	if turn_dir > 0:
		character.anim_player.play("TurnLeft")
	elif turn_dir < 0:
		character.anim_player.play("TurnRight")
	else:
		if target_dir == Vector2.DOWN or target_dir == Vector2.LEFT:
			character.anim_player.play("TurnLeft")
		else:
			character.anim_player.play("TurnRight")
	
	var new_rot := new_basis.get_rotation_quaternion()
	var tween = create_tween()
	tween.tween_method(func(weight : float):
		var temp_rot := character.quaternion.slerp(new_rot, weight)
		character.rotation = snapped(temp_rot.get_euler(), Vector3(PI/4, PI/4, PI/4)),
		0.0, 1.0, 0.25)
	await tween.finished
	if !character.state_machine.current_state is AttackState:
		character.anim_player.play("Walk")
	turning = false


func _set_target_square() -> void:
	var target : Vector2 = character.target_square
	var char_pos := Utilities.v3_to_v2(character.global_position)
	var min_dist := 9999
	for egg_square in get_tree().get_nodes_in_group("EggSquares"):
		var egg_pos := Utilities.v3_to_v2(egg_square.global_position)
		if char_pos.direction_to(egg_pos) \
						.dot(Utilities.get_move_dir_vect(character.move_dir)) <= 0:
			continue
		if char_pos.distance_squared_to(egg_pos) < min_dist:
			min_dist = char_pos.distance_squared_to(egg_pos)
			target = egg_pos
	character.target_square = target
	
	# Debug
	character.debug_target.global_position = Vector3(target.x, 0.05, target.y)


func respawn() -> void:
	character.velocity = Vector3.ZERO
	transition.emit(self, "IdleState")
	character.target_square = Utilities.v3_to_v2(character.global_position)
	
	# Debug
	character.debug_target.global_position = \
				Vector3(character.target_square.x, 0.05, character.target_square.y)


#func exit() -> void: pass
#func update(delta) -> void: pass
