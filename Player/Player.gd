class_name Player extends CharacterBody3D


@export var debug_target : MeshInstance3D

signal game_over

@onready var anim_player := $AnimPlayer
@onready var attack_cast := $AttackCast
@onready var attack_sfx := $AttackSFX
@onready var hit_sfx := $HitSFX

const ACCEL := 15.0
const MAX_SPEED := 4.5
const MIN_SPEED := 1.5
var speed := 3.0

@export var state_machine : StateMachine
enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }
var move_dir : DIRECTIONS = DIRECTIONS.DOWN
@export var wall_check : RayCast3D
var target_square : Vector2


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


func attack() -> void:
	if anim_player.current_animation == "Attack":
		anim_player.seek(0.0)
	else:
		anim_player.play("Attack")
	
	attack_sfx.pitch_scale = randf_range(0.95, 1.05)
	attack_sfx.play()
	
	attack_cast.force_shapecast_update()
	if attack_cast.is_colliding():
		hit_sfx.pitch_scale = randf_range(0.95, 1.05)
		hit_sfx.play()
		for collision in attack_cast.collision_result:
			if collision.collider is Enemy:
				collision.collider.attacked(move_dir)


func _attack_ended() -> void:
	if state_machine.current_state is AttackState:
		state_machine.current_state.attack_finished()


func attacked() -> void:
	respawn()


func respawn() -> void:
	Globals.add_to_player_lives(-1)
	if Globals.player_lives == -1:
		Globals.reset_game()
		game_over.emit()
	
	var respawn_pos = Utilities.get_closest_egg_square(global_position).global_position
	position = Vector3(respawn_pos.x, 0, respawn_pos.z)
	rotation = Vector3(0, PI, 0)
	velocity = Vector3.ZERO
	state_machine.current_state.respawn()
	target_square = Vector2(position.x, position.z)
	move_dir = DIRECTIONS.DOWN


func effect_speed(speed_effect : float) -> void:
	speed += speed_effect
	speed = clamp(speed, MIN_SPEED, MAX_SPEED)
