class_name HitStunState extends State


const ATTACKS_TO_KILL := 3
@onready var attacked_timer := $StunTimer
var attacked_num := 0


func enter() -> void:
	#print(character.name, ": Enter HitStunState")
	attacked()


func attacked() -> void:
	attacked_timer.start()
	attacked_num += 1
	
	if attacked_num == ATTACKS_TO_KILL:
		attacked_timer.stop()
		transition.emit(self, "DeathState")


func reset_attacked() -> void:
	attacked_num = 0
	transition.emit(self, character.get_prev_state())


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
