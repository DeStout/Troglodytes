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
	if character.has_method("is_invincible") and character.is_invincible():
		return
	
	despawn_timer.stop()
	collision.call_deferred("set_disabled", true)
	if character is Player:
		character.pit_fall.rpc_id(character.get_multiplayer_authority(), get_path())
	elif character is Enemy:
		character.pit_fall(self)


@rpc("any_peer", "call_local", "reliable")
func close() -> void:
	anim_player.play_backwards("OpenClose_2")
	if multiplayer.is_server():
		await anim_player.animation_finished
		_despawn()
