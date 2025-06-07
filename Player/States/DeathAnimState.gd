class_name DeathAnimState extends State


@export var anim_player : AnimationPlayer


func enter() -> void:
	character.velocity = Vector3.ZERO
	character.anim_player.speed_scale = 1.0


func die() -> void:
	character.die()
	transition.emit(self, "StartState")
	
	
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
#func exit() -> void: pass
