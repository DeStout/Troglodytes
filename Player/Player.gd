class_name Player extends CharacterBody3D


@export var debug_target : MeshInstance3D

signal game_over
signal spawn_footprint
signal freeze_pick_up
signal spawn_fire_ball

const INIT_LIVES := 2
const MAX_LIVES := 3
var num_lives := INIT_LIVES

@onready var attack_cast := $AttackCast
@onready var attack_sfx := $AttackSFX
@onready var hit_sfx := $HitSFX

const ACCEL := 15.0
const MAX_SPEED := 4.5
const MIN_SPEED := 1.5
@onready var state_machine := $StateMachine
@onready var anim_player : AnimationPlayer = $Player1/AnimationPlayer
@onready var right_foot := $Player1/Armature/Skeleton3D/RightFootBone/RightFoot
@onready var left_foot := $Player1/Armature/Skeleton3D/LeftFootBone/LeftFoot
@onready var wall_check := $WallCheck
var speed := 3.0
var anim_speed := 1.0
var move_dir : Utilities.DIRECTIONS = Utilities.DIRECTIONS.DOWN
var target_square : Vector2


const START_INV_TIME := 5.0
const INVINCIBLE_TIME := 8.0
const INV_FLASH_TIME := 1.25
const FIRE_POWER_TIME := 10.0
@onready var invincible_timer := $InvincibleTimer
@onready var halo := $Halo
@onready var fire_power_timer := $FirePowerTimer
@onready var fire_sfx := $FireSFX
@onready var stars := $Player1/Armature/Skeleton3D/HeadBone/Stars


func get_prev_state() -> String:
	return state_machine.prev_state.name.to_lower()


func ray_check(check_dir : Utilities.DIRECTIONS) -> bool:
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


func _footstep(foot_down : bool) -> void:
	spawn_footprint.emit(self, foot_down)


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
			if !collision.collider is Enemy:
				return
			collision.collider.attacked(move_dir)


func _attack_ended() -> void:
	if state_machine.current_state is AttackState:
		state_machine.current_state.attack_finished()


func effect_speed(speed_effect : float) -> void:
	speed += speed_effect
	anim_speed += sign(speed_effect) * 0.2
	anim_player.speed_scale = anim_speed
	speed = clamp(speed, MIN_SPEED, MAX_SPEED)


func set_invincible(inv_time := INVINCIBLE_TIME) -> void:
	halo.visible = true
	invincible_timer.start(inv_time)
	var flash_timer = get_tree().create_timer(inv_time - INV_FLASH_TIME, false)
	flash_timer.timeout.connect(flash_halo.bind(0.0))


func flash_halo(vis_time : float) -> void:
	var inv_time_left = snappedf(invincible_timer.time_left, 0.01)
	if !invincible_timer.time_left or inv_time_left > INV_FLASH_TIME:
		halo.visible = invincible_timer.time_left
		return
	
	halo.visible = !halo.visible
	vis_time = vis_time * (2.0 / 3.0) if bool(vis_time) else 0.4
	vis_time = max(vis_time, 0.05)
	var flash_time = vis_time if halo.visible else 0.05
	var flash_timer = get_tree().create_timer(flash_time, false)
	flash_timer.timeout.connect(flash_halo.bind(vis_time))


func is_invincible() -> bool:
	return bool(invincible_timer.time_left)


func give_fire_power() -> void:
	fire_power_timer.start(FIRE_POWER_TIME)


func apply_freeze() -> void:
	# Signal to Characters.freeze_enemies()
	freeze_pick_up.emit()


func attacked() -> void:
	if state_machine.current_state.has_method("attacked"):
		state_machine.current_state.attacked()


func show_stars(show : bool) -> void:
	stars.set_process(show)
	stars.visible = show


func add_lives(num : int ) -> void:
	num_lives = min(MAX_LIVES, num_lives + num)


func die() -> void:
	num_lives -= 1
	if num_lives == -1:
		Globals.reset_game()
		# Signal to Level.game_over()
		game_over.emit()
		return
	respawn()


func respawn() -> void:
	speed = (MAX_SPEED + MIN_SPEED) / 2
	fire_power_timer.stop()
	var respawn_pos = Utilities.get_closest_egg_square(global_position).global_position
	position = Vector3(respawn_pos.x, 0, respawn_pos.z)
	rotation = Vector3(0, PI, 0)
	velocity = Vector3.ZERO
	target_square = Vector2(position.x, position.z)
	move_dir = Utilities.DIRECTIONS.DOWN
