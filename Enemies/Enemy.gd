class_name Enemy extends CharacterBody3D


const SCORE_VALUE := 1000

@export var characters : Node3D
@export var state_machine : Node

const ACCEL := 15.0
var speed := 3.0

enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }
var move_dir : DIRECTIONS = DIRECTIONS.DOWN
@export var wall_check : RayCast3D
var death_dir : DIRECTIONS
var target_square : Vector2


func spawn_finished() -> void:
	characters.enemy_finished_spawning(Utilities.get_closest_egg_square(global_position))


func get_prev_state() -> String:
	return state_machine.prev_state.name.to_lower()


func ray_check(check_dir : DIRECTIONS) -> bool:
	var local_dir : Vector3
	match check_dir:
		0:
			local_dir = Vector3(0, 0, -1) + wall_check.global_position
		1:
			local_dir = Vector3(0, 0, 1) + wall_check.global_position
		2:
			local_dir = Vector3(-1, 0, 0) + wall_check.global_position
		3:
			local_dir = Vector3(1, 0, 0) + wall_check.global_position
	wall_check.target_position = wall_check.to_local(local_dir)
	wall_check.force_raycast_update()
	return wall_check.is_colliding()


func get_move_dir_vect(move_dir : int) -> Vector2:
	var target_dir : Vector2
	match move_dir:
		0:
			target_dir = Vector2.UP
		1:
			target_dir = Vector2.DOWN
		2:
			target_dir = Vector2.LEFT
		3:
			target_dir = Vector2.RIGHT
	return target_dir


func _body_attackable(character : CharacterBody3D) -> void:
	if character is Player:
		if state_machine.current_state.has_method("attack"):
			state_machine.current_state.attack()


func attacked(attack_dir : int) -> void:
	death_dir = attack_dir
	if state_machine.current_state.has_method("attacked"):
		state_machine.current_state.attacked()


func get_body() -> MeshInstance3D:
	return $Body


func freeze() -> void:
	if state_machine.current_state.has_method("freeze"):
		state_machine.current_state.freeze()


func unfreeze() -> void:
	if state_machine.current_state.has_method("unfreeze"):
		state_machine.current_state.unfreeze()


func burn() -> void:
	queue_free()


func disable_collision() -> void:
	$Collision.call_deferred("set_disabled", true)


func die() -> void:
	characters.enemy_defeated(self)
	queue_free()
