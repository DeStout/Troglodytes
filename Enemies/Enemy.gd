class_name Enemy extends CharacterBody3D


signal spawn_footprint

const SCORE_VALUE := 1000

@export var characters : MultiplayerSpawner
@export var body : MeshInstance3D
@export var state_machine : Node
@export var anim_player : AnimationPlayer
@export var right_foot : Node3D
@export var left_foot : Node3D

const ACCEL := 15.0
var speed := 3.0

enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }
var move_dir : DIRECTIONS = DIRECTIONS.DOWN
@export var wall_check : RayCast3D
var death_dir : DIRECTIONS
var target_square : Vector2

var spawn_hole : CSGCylinder3D


func spawn_finished() -> void:
	spawn_hole.close()
	characters.enemy_finished_spawning(Utilities.get_closest_egg_square(global_position))


func get_prev_state() -> String:
	return state_machine.prev_state.name.to_lower()


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


func _footstep(foot_down : bool) -> void:
	spawn_footprint.emit(self, foot_down)


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
	if spawn_hole:
		spawn_hole.close()
	characters.enemy_defeated(self)
	queue_free()
