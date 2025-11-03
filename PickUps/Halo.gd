extends PickUp


const ROTATION_SPEED := 60.0
const AMPLITUDE := 0.1

@export var anim_player : AnimationPlayer

@onready var pos_offset : float = mesh.position.y
@onready var time_offset := randf() * TAU
var rot := rad_to_deg(randf() * TAU)
var time := 0.0


func _ready() -> void:
	set_process(false)
	rotation.y = randf_range(0, TAU)
	anim_player.play("Descend")

	if multiplayer.is_server():
		apply_effect = _set_invincible

		await anim_player.animation_finished
		collision.set_deferred("disabled", !multiplayer.is_server())
		set_process(true)
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _process(delta: float) -> void:
	time += delta
	rot = fmod(rot + (ROTATION_SPEED * delta), 360)
	if is_zero_approx(snapped(fmod(time, 0.25), 0.05)):
		rotation_degrees.y = rot
		mesh.position.y = pos_offset + AMPLITUDE * sin(time + time_offset)


func _despawn() -> void:
	collision.set_deferred("disabled", true)
	_despawn_anim.rpc()
	await anim_player.animation_finished
	super()


@rpc("authority", "call_local")
func _despawn_anim() -> void:
	anim_player.play("Despawn")
