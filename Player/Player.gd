class_name Player extends CharacterBody3D


@export var debug_target : MeshInstance3D

signal game_over
signal freeze_pick_up
signal spawn_fire_ball

@onready var anim_player: AnimationPlayer = $Player1/AnimationPlayer
#@onready var anim_player := $AnimPlayer
@onready var fire_power_timer := $FirePowerTimer
@onready var attack_cast := $AttackCast
@onready var attack_sfx := $AttackSFX
@onready var hit_sfx := $HitSFX

const ACCEL := 15.0
const MAX_SPEED := 4.5
const MIN_SPEED := 1.5
var speed := 3.0
var anim_speed := 1.0
const FIRE_POWER_TIME := 10.0
@export var fire_sfx : AudioStreamPlayer

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
		-1:
			return false
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
	if fire_power_timer.time_left:
		fire_sfx.play()
		# Signal to Level.spawn_fire_ball()
		spawn_fire_ball.emit(self)
		state_machine.current_state.attack_finished()
		return
		
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
		# Signal to Level.game_over()
		game_over.emit()
	
	speed = (MAX_SPEED + MIN_SPEED) / 2
	anim_speed = 1.0
	var respawn_pos = Utilities.get_closest_egg_square(global_position).global_position
	position = Vector3(respawn_pos.x, 0, respawn_pos.z)
	rotation = Vector3(0, PI, 0)
	velocity = Vector3.ZERO
	state_machine.current_state.respawn()
	target_square = Vector2(position.x, position.z)
	move_dir = DIRECTIONS.DOWN


func effect_speed(speed_effect : float) -> void:
	speed += speed_effect
	anim_speed += sign(speed_effect) * 0.2
	anim_player.speed_scale = anim_speed
	speed = clamp(speed, MIN_SPEED, MAX_SPEED)


func give_fire_power() -> void:
	fire_power_timer.start(FIRE_POWER_TIME)


func apply_freeze() -> void:
	# Signal to Characters.freeze_enemies()
	freeze_pick_up.emit()
