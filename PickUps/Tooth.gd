extends PickUp


@export var bob_time := 4.0
@export var bob_dist := 0.1
@export var rotate_time := 5.0
@export var rotate_degs := 10.0
var time := 0.0


func _ready() -> void:
	time = randf() * rotate_time
	if multiplayer.is_server():
		apply_effect = _dinomight
		collision.set_deferred("disabled", !multiplayer.is_server())
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _process(delta: float) -> void:
	if is_zero_approx(snapped(fmod(time, 0.25), 0.05)):
		mesh.position.y = bob_dist * sin((TAU / bob_time) * time)
		mesh.rotation_degrees.y = rotate_degs * sin((TAU / rotate_time) * time)
	time += delta



func _despawn() -> void:
	collision.set_deferred("disabled", true)
	super()
