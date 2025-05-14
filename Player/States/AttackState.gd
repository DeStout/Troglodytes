class_name AttackState extends State


@export var input_sync : Node


func _ready() -> void:
	input_sync.input_update.connect(_update_input)


func enter() -> void:
	#print("Enter AttackState")
	character.anim_player.speed_scale = 1.0
	character.attack()
	character._footstep(true)
	character._footstep(false)


func _update_input(new_input : Dictionary[String, Variant]) -> void:
	if !active:
		return
		
	if new_input["attack_input"]:
		character.attack()


func attack_finished() -> void:
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	if !character.invincible_timer.time_left:
		transition.emit(self, "StunState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
