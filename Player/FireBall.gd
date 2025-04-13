extends Node3D


const SPEED := 16.0

var emitter : Player
var move_dir : Utilities.DIRECTIONS


func align_to_dir() -> void:
	var target_dir := Utilities.get_move_dir_vect(move_dir)
	basis = basis.looking_at(Vector3(target_dir.x, 0, target_dir.y))


func _physics_process(delta: float) -> void:
	var dir2 := Utilities.get_move_dir_vect(move_dir)
	var dir3 := Vector3(dir2.x, 0, dir2.y)
	position += dir3 * SPEED * delta


func _body_collided(body : Node3D) -> void:
	if !body is CharacterBody3D:
		queue_free()
		return
	if body != emitter:
		body.burn()
		queue_free()


func _despawn() -> void:
	queue_free()
