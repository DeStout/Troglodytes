extends PickUp


@export var anim_player : AnimationPlayer


func _ready() -> void:
	rotation.y = randf_range(0, TAU)
	anim_player.play("Grow")
	
	if multiplayer.is_server():
		apply_effect = _effect_speed.bind(0.5)
		
		await anim_player.animation_finished
		collision.set_deferred("disabled", !multiplayer.is_server())
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _despawn() -> void:
	#collision.set_deferred("disabled", true)
	_despawn_anim.rpc()
	await anim_player.animation_finished
	super()


@rpc("authority", "call_local")
func _despawn_anim() -> void:
	anim_player.play("Die")
