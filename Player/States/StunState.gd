class_name StunState extends State


const STUN_TIME := 3.0

@onready var stun_timer := $StunTimer


func enter() -> void:
	#print("Enter StunState")
	stun_timer.start(STUN_TIME)
	character.anim_player.speed_scale = 1.0
	character.anim_player.play("Stunned")
	character.show_stars(true)
	character.velocity = Vector3.ZERO


# Called from stun_timer.timeout
func _die() -> void:
	character.die()
	transition.emit(self, "StartState")


func exit() -> void:
	character.show_stars(false)
	
	
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
