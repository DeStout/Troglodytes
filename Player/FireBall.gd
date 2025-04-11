extends Node3D


enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }

const SPEED := 16.0

var emitter : Player
var move_dir : DIRECTIONS


func _physics_process(delta: float) -> void:
	var dir2 := _get_move_dir_vect()
	var dir3 := Vector3(dir2.x, 0, dir2.y)
	position += dir3 * SPEED * delta


func _get_move_dir_vect() -> Vector2:
	var target_dir : Vector2
	match move_dir:
		DIRECTIONS.UP:
			target_dir = Vector2.UP
		DIRECTIONS.DOWN:
			target_dir = Vector2.DOWN
		DIRECTIONS.LEFT:
			target_dir = Vector2.LEFT
		DIRECTIONS.RIGHT:
			target_dir = Vector2.RIGHT
	return target_dir


func _body_collided(body : Node3D) -> void:
	if !body is CharacterBody3D:
		queue_free()
		return
	if body != emitter:
		body.burn()
		queue_free()


func _despawn() -> void:
	queue_free()
