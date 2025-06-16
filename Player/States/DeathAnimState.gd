class_name DeathAnimState extends State


@export var anim_player : AnimationPlayer


func enter() -> void:
	#print("%s-%s: Enter DeathAnimState" % [multiplayer.get_unique_id(), character.get_multiplayer_authority()])
	
	character.velocity = Vector3.ZERO
	character.anim_player.speed_scale = 1.0


func player_die() -> void:
	character.die()
	transition.emit(self, "StartState")


func enemy_die() -> void:
	pass
	
	
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
#func exit() -> void: pass
