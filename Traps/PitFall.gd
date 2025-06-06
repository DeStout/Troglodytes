extends Trap


@export var anim_player : AnimationPlayer


func _ready() -> void:
	anim_player.play("OpenClose_2")
	if multiplayer.is_server():
		trap_trigger = _character_entered
		await anim_player.animation_finished
		despawn_timer.start(randf_range(despawn_range.x, despawn_range.y))
		collision.set_deferred("disabled", false)


func _character_entered(character : CharacterBody3D) -> void:
	if character.has_method("pit_fall"):
		character.pit_fall(self)


func _despawn() -> void:
	_despawn_anim.rpc()
	await anim_player.animation_finished
	super()


@rpc("authority", "call_local")
func _despawn_anim() -> void:
	anim_player.play_backwards("OpenClose_2")
