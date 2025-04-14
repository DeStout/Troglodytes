class_name AttackState extends State


func enter() -> void:
	#print("Enter AttackState")
	character.anim_player.speed_scale = 1.0
	character.attack()
	character._footstep(true)
	character._footstep(false)


func exit() -> void:
	pass


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey and event.is_action_pressed("Attack"):
		character.attack()
	elif event is InputEventMouseButton and event.is_action_pressed("Attack"):
		character.attack()


func update(delta) -> void:
	pass


func physics_update(delta) -> void:
	pass


func attack_finished() -> void:
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	if !character.invincible_timer.time_left:
		transition.emit(self, "StunState")
