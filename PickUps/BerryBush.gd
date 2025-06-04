extends PickUp


@export var anim_player : AnimationPlayer


func _ready() -> void:
	rotation.y = randf_range(0, TAU)
	print(position)
	print(rotation_degrees.y)
	print()
	apply_effect = _effect_speed.bind(0.5)
	anim_player.play("Grow")
	
	await anim_player.animation_finished
	collision.disabled = !multiplayer.is_server()
	if multiplayer.is_server():
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))
