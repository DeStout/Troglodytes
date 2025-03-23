class_name HitStunState extends State


const ATTACKS_TO_KILL := 3
@onready var attacked_timer := $StunTimer
var attacked_num := 0
var tween : Tween


func enter() -> void:
	#print(character.name, ": Enter HitStunState")
	attacked()


func attacked() -> void:
	attacked_timer.start()
	attacked_num += 1
	
	if attacked_num == ATTACKS_TO_KILL:
		attacked_timer.stop()
		transition.emit(self, "DeathState")
	if tween:
		tween.kill()
		character.get_body().position = Vector3.UP
	_hit_jitter()


func _hit_jitter() -> void:
	var death_dir : Vector2 = character.get_move_dir_vect(character.death_dir) * 0.25
	var jitter_pos := character.global_position + Vector3(death_dir.x, 1.0, death_dir.y)
	tween = create_tween()
	tween.tween_property(character.get_body(), "global_position", jitter_pos, 0.05)
	tween.tween_property(character.get_body(), "position", Vector3.UP, 0.05)


func reset_attacked() -> void:
	attacked_num = 0
	transition.emit(self, character.get_prev_state())


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
