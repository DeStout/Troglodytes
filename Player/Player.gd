class_name Player extends CharacterBody3D


@export var debug_target : MeshInstance3D

signal spawn_footprint
signal freeze_pick_up
signal spawn_fire_ball

@export var player_input : Node

@onready var collision := $Collision
@onready var attack_cast := $AttackCast
@onready var attack_sfx := $AttackSFX
@onready var hit_sfx := $HitSFX

const ACCEL := 15.0
const MAX_SPEED := 4.5
const MIN_SPEED := 1.5
const MAX_ANIM_SPEED := 1.6
const MIN_ANIM_SPEED := 0.4
@onready var state_machine := $StateMachine
@onready var anim_player : AnimationPlayer = $Player/AnimationPlayer
@onready var right_foot := $Player/Armature/Skeleton3D/RightFootBone/RightFoot
@onready var left_foot := $Player/Armature/Skeleton3D/LeftFootBone/LeftFoot
@onready var wall_check := $WallCheck
var speed := 3.0
var anim_speed := 1.0
var move_dir : Utilities.DIRECTIONS = Utilities.DIRECTIONS.DOWN
var target_square : Vector2


const START_INV_TIME := 4.0
const INVINCIBLE_TIME := 8.0
const INV_FLASH_TIME := 1.25
const FIRE_POWER_TIME := 10.0
@onready var skin := $Player/Armature/Skeleton3D/PlayerBody
var player_mat := load("res://Player/PlayerSkin_mat.tres").duplicate()
@onready var invincible_timer := $InvincibleTimer
@onready var halo := $Halo
@onready var fire_power_timer := $FirePowerTimer
@onready var fire_sfx := $FireSFX
@onready var stars := $Player/Armature/Skeleton3D/HeadBone/Stars


func _ready() -> void:
	skin.set_surface_override_material(0, player_mat)
	player_input.set_process_input(is_multiplayer_authority())
	collision.disabled = !multiplayer.is_server()
	attack_cast.enabled = multiplayer.is_server()


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
	#print(get_multiplayer_authority(), " footstep ", multiplayer.get_unique_id())
	spawn_footprint.emit(self, foot_down)


@rpc("call_local", "reliable")
func attack() -> void:
	if !multiplayer.is_server() and !is_multiplayer_authority():
		return
	
	if is_multiplayer_authority():
		if anim_player.current_animation == "Attack":
			anim_player.stop()
		await get_tree().physics_frame
		anim_player.play("Attack")
		_play_attack_sfx.rpc(get_path_to(attack_sfx))
	if multiplayer.is_server():
		attack_cast.force_shapecast_update()
		if attack_cast.is_colliding():
			_play_attack_sfx.rpc(get_path_to(hit_sfx))
				
			var collisions : Array = attack_cast.collision_result
			for collision in collisions:
				if collision.collider is Enemy:
					collision.collider.attacked(move_dir)
				elif collisions.has(Enemy):
					print(collision.name)
					pass


@rpc("call_local", "reliable")
func fire_power_attack() -> void:
	if multiplayer.is_server():
		spawn_fire_ball.emit(self)
	if is_multiplayer_authority():
		_play_attack_sfx.rpc(get_path_to(fire_sfx))
		state_machine.current_state.attack_finished()


@rpc("any_peer", "call_local")
func _play_attack_sfx(sfx_path : NodePath) -> void:
	get_node(sfx_path).play()


func _attack_ended() -> void:
	if state_machine.current_state is AttackState:
		state_machine.current_state.attack_finished()


@rpc("call_local", "any_peer")
func effect_speed(speed_effect : float) -> void:
	speed += speed_effect
	anim_speed += sign(speed_effect) * 0.2
	anim_speed = clamp(anim_speed, MIN_ANIM_SPEED, MAX_ANIM_SPEED)
	anim_player.speed_scale = anim_speed
	speed = clamp(speed, MIN_SPEED, MAX_SPEED)


@rpc("call_local", "any_peer")
func set_invincible(inv_time := INVINCIBLE_TIME) -> void:
	halo.visible = true
	invincible_timer.start(inv_time)
	var flash_timer = get_tree().create_timer(inv_time - INV_FLASH_TIME, false)
	flash_timer.timeout.connect(flash_halo.bind(0.0))


func flash_halo(vis_time : float) -> void:
	var inv_time_left = snappedf(invincible_timer.time_left, 0.05)
	if !invincible_timer.time_left or inv_time_left > INV_FLASH_TIME:
		halo.visible = invincible_timer.time_left
		return
	
	halo.visible = !halo.visible
	vis_time = vis_time * (2.0 / 3.0) if bool(vis_time) else 0.4
	vis_time = max(vis_time, 0.05)
	var flash_time = vis_time if halo.visible else 0.05
	if !is_inside_tree():
		await tree_entered
	var flash_timer = get_tree().create_timer(flash_time, false)
	flash_timer.timeout.connect(flash_halo.bind(vis_time))


func is_invincible() -> bool:
	return bool(invincible_timer.time_left)


@rpc("any_peer", "call_local")
func give_fire_power() -> void:
	fire_power_timer.start(FIRE_POWER_TIME)


func apply_freeze() -> void:
	# Signal to Characters.freeze_enemies()
	freeze_pick_up.emit()


@rpc("any_peer", "call_local", "reliable")
func attacked() -> void:
	if state_machine.current_state.has_method("attacked"):
		state_machine.current_state.attacked()


@rpc("call_local", "any_peer")
func exit_stage() -> void:
	if !invincible_timer.time_left:
		die()
	else:
		respawn()
	if state_machine.current_state.has_method("exit_stage"):
		state_machine.current_state.exit_stage()


@rpc("any_peer", "call_local")
func pit_fall() -> void:
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	die()
	state_machine.current_state.transition.emit(state_machine.current_state, "StartState")


func die() -> void:
	respawn()


func respawn() -> void:
	speed = (MAX_SPEED + MIN_SPEED) / 2
	anim_speed = (MAX_ANIM_SPEED + MIN_ANIM_SPEED) / 2
	anim_player.speed_scale = anim_speed
	
	fire_power_timer.stop()
	var respawn_pos = Utilities.get_closest_egg_square(global_position).global_position
	position = Vector3(respawn_pos.x, 0, respawn_pos.z)
	rotation = Vector3(0, PI, 0)
	velocity = Vector3.ZERO
	target_square = Vector2(position.x, position.z)
	move_dir = Utilities.DIRECTIONS.DOWN
