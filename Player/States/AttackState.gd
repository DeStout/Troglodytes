class_name AttackState extends State


func enter() -> void:
	#print("Enter AttackState")
	character.attack()


func exit() -> void:
	pass


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey and event.is_action_pressed("Attack"):
		character.attack()


func update(delta) -> void:
	pass


func physics_update(delta) -> void:
	pass


func attack_finished() -> void:
	transition.emit(self, character.get_prev_state())


func respawn() -> void:
	transition.emit(self, "IdleState")
