class_name SearchState extends State


const SNAP_TOL := 0.005

@export var anim_player : AnimationPlayer
@export var wall_check : RayCast3D
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
		return


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



func _slerp_to_dirp() -> void:
	var target_dir := Utilities.get_move_dir_vect(character.move_dir)
	# Do nothing if already facing the correct direction
	if target_dir == Utilities.v3_to_v2(-character.basis.z):
		return
	
	turning = true
	var new_basis = Basis.looking_at(Utilities.v2_to_v3(target_dir))
	var new_rot := new_basis.get_rotation_quaternion()
	tween = create_tween()
	tween.tween_method(func(weight : float):
		var temp_rot := character.quaternion.slerp(new_rot, weight)
		character.rotation = snapped(temp_rot.get_euler(), Vector3(PI/4, PI/4, PI/4)),
		0.0, 1.0, 0.25)
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


func burn() -> void:
	anim_player.stop()
	tween.stop()
	transition.emit(self, "BurnState")


#func exit() -> void: pass
#func update(delta) -> void: pass
