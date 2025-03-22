class_name BashState extends State


@export var anim_player : AnimationPlayer
@export var attack_cast : ShapeCast3D
@export var bash_sfx : AudioStreamPlayer


func enter() -> void:
	#print(character.name, ": Enter BashState")
	anim_player.animation_finished.connect(_attack_finished)
	anim_player.play("Attack")


func bash() -> void:
	attack_cast.force_shapecast_update()
	if attack_cast.is_colliding():
		for collision in attack_cast.collision_result:
			if collision.collider is Player:
				bash_sfx.play()
				collision.collider.attacked()


func _attack_finished(_anim_finished : String) -> void:
	anim_player.animation_finished.disconnect(_attack_finished)
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	anim_player.pause()
	anim_player.animation_finished.disconnect(_attack_finished)
	transition.emit(self, "HitStunState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
