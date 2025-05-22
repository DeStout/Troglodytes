class_name HitStunState extends State


const ATTACKS_TO_KILL := 3
@onready var stun_timer := $StunTimer
var attacked_num := 0
var tween : Tween


func enter() -> void:
	#print(character.name, ": Enter HitStunState")
	if tween and tween.is_valid():
		stun_timer.start()
		tween.play()
		return
	attacked()


func attacked() -> void:
	stun_timer.start()
	attacked_num += 1
	
	if attacked_num == ATTACKS_TO_KILL and multiplayer.is_server():
		stun_timer.stop()
		transition.emit(self, "DeathState")
	if tween:
		tween.kill()
		character.body.position = Vector3.ZERO
	_hit_jitter.rpc(character.death_dir)


@rpc("any_peer", "call_local")
func _hit_jitter(death_dir : Utilities.DIRECTIONS) -> void:
	var death_vect : Vector2 = Utilities.get_move_dir_vect(death_dir) * 0.25
	var jitter_pos := character.global_position + Vector3(death_vect.x, 0.0, death_vect.y)
	tween = create_tween()
	tween.tween_property(character.body, "global_position", jitter_pos, 0.05)
	tween.tween_property(character.body, "position", Vector3.ZERO, 0.05)


func reset_attacked() -> void:
	attacked_num = 0
	if tween:
		tween.kill()
	transition.emit(self, character.get_prev_state())


func freeze() -> void:
	tween.pause()
	stun_timer.paused = true
	transition.emit(self, "FreezeState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
