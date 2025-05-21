class_name MoveState extends State


const SNAP_TOL := 0.007

@export var input_sync : Node
var dir_buffer : Utilities.DIRECTIONS
var turning := false


func enter() -> void:
	#print("Enter MoveState")
	
	input_sync.input_update.connect(_update_input)
	
	character.anim_player.speed_scale = character.anim_speed
	character.anim_player.play("Walk")
	
	var dir_input : Vector2 = input_sync.get_player_input()["dir_input"]
	dir_input = _clear_same_dir_input(dir_input)
	var move_dir := Utilities.get_move_dir(dir_input)
	dir_buffer = move_dir if move_dir != -1 else character.move_dir
	
	if _is_turn_around():
		_turn_around()
	_set_target_square()
	await _slerp_to_dirp()


func _update_input(new_input : Dictionary[String, Variant]) -> void:
	if !active:
		return
	
	if new_input["attack_input"]:
		transition.emit(self, "AttackState")
	
	var dir_input : Vector2 = new_input["dir_input"]
	dir_input = _clear_same_dir_input(dir_input)
	var move_dir := Utilities.get_move_dir(dir_input)
	if move_dir == -1 or move_dir == dir_buffer:
		return
	dir_buffer = move_dir
	
	if _is_turn_around():
		_turn_around()
	_set_target_square()
	await _slerp_to_dirp()


func _clear_same_dir_input(dir_input : Vector2) -> Vector2:
	var move_dir := Utilities.get_move_dir_vect(character.move_dir)
	if is_equal_approx(move_dir.x, dir_input.x):
		dir_input.x = 0
	if is_equal_approx(move_dir.y, dir_input.y):
		dir_input.y = 0
	return dir_input


func physics_update(delta) -> void:
	if turning:
		return
		
	_move(delta)
	if !_is_at_target():
		return
		
	# [bool, bool]
	var walls := [character.ray_check(character.move_dir), \
											character.ray_check(dir_buffer)]
	if character.move_dir != dir_buffer:
		# Turn if no wall in input direction
		if !walls[1]:
			_stop_and_snap()
			character.move_dir = dir_buffer
			_set_target_square()
			await _slerp_to_dirp()
			return
		# Stop if wall ahead
		if walls[0]:
			_stop_and_snap()
			transition.emit(self, "IdleState")
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


func _is_turn_around() -> bool:
	if dir_buffer == Utilities.DIRECTIONS.UP and \
									character.move_dir == Utilities.DIRECTIONS.DOWN:
		return true
	if dir_buffer == Utilities.DIRECTIONS.DOWN and \
									character.move_dir == Utilities.DIRECTIONS.UP:
		return true
	if dir_buffer == Utilities.DIRECTIONS.LEFT and \
									character.move_dir == Utilities.DIRECTIONS.RIGHT:
		return true
	if dir_buffer == Utilities.DIRECTIONS.RIGHT and \
									character.move_dir == Utilities.DIRECTIONS.LEFT:
		return true
	return false


func _turn_around() -> void:
	var char_pos := Utilities.v3_to_v2(character.global_position)
	character.velocity = Vector3.ZERO
	character.move_dir = dir_buffer


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
	if !active:
		return
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


func attacked() -> void:
	if !character.invincible_timer.time_left:
		transition.emit(self, "StunState")


func exit_stage() -> void:
	transition.emit(self, "StartState")


func exit() -> void:
	input_sync.input_update.disconnect(_update_input)
	
	
#func update(delta) -> void: pass
