class_name SearchState extends State


const SNAP_TOL := 0.005

@export var anim_player : AnimationPlayer
var turning := false
var tween : Tween


func enter() -> void:
	#print(character.name, ": Enter SearchState")
	anim_player.play("Run")
	if tween and tween.is_valid():
		tween.play()
		return
	_slerp_to_dirp()


func physics_update(delta) -> void:
	if turning:
		return
	
	_move(delta)
	if _is_at_target():
		character.position.x = character.target_square.x
		character.position.z = character.target_square.y
		character.velocity = Vector3.ZERO
		transition.emit(self, "ThinkState")


func _move(delta : float) -> void:
	var move_dir := _get_move_dir_vect()
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


func _get_move_dir_vect() -> Vector2:
	var target_dir : Vector2
	match character.move_dir:
		character.DIRECTIONS.UP:
			target_dir = Vector2.UP
		character.DIRECTIONS.DOWN:
			target_dir = Vector2.DOWN
		character.DIRECTIONS.LEFT:
			target_dir = Vector2.LEFT
		character.DIRECTIONS.RIGHT:
			target_dir = Vector2.RIGHT
	return target_dir


func _slerp_to_dirp() -> void:
	var target_dir := _get_move_dir_vect()
	# Do nothing if already facing the correct direction
	if target_dir == Utilities.v3_to_v2(-character.basis.z):
		return
	
	turning = true
	var new_basis = character.basis.looking_at(Vector3(target_dir.x, 0, target_dir.y))
	tween = create_tween()
	tween.tween_method(func(weight : float):
		character.basis = character.basis.slerp(new_basis, weight), 
																0.0, 1.0, 0.15)
	await tween.finished
	turning = false
	return


func attack() -> void:
	transition.emit(self, "BashState")


func attacked() -> void:
	anim_player.pause()
	tween.pause()
	transition.emit(self, "HitStunState")


func freeze() -> void:
	anim_player.pause()
	tween.pause()
	transition.emit(self, "FreezeState")


#func exit() -> void: pass
#func update(delta) -> void: pass
