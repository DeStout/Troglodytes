extends PickUp


@export var anim_player : AnimationPlayer


func _ready() -> void:
	mesh.rotation.y = randf_range(-PI/2, PI/2)
	apply_effect = _apply_freeze
	anim_player.play("GrowMelt")
	
	await anim_player.animation_finished
	collision.set_deferred("disabled", !multiplayer.is_server())
	if multiplayer.is_server():
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _despawn() -> void:
	collision.set_deferred("disabled", true)
	anim_player.play_backwards("GrowMelt")
	await anim_player.animation_finished
	super()
