class_name Enemy extends CharacterBody3D


signal spawn_footprint

const SCORE_VALUE := 1000

var play_area : Area3D
@export var characters : MultiplayerSpawner
@export var body : MeshInstance3D
@export var collision : CollisionShape3D
@export var attack_collision : CollisionShape3D
@export var state_machine : Node
@export var anim_player : AnimationPlayer
@export var right_foot : Node3D
@export var left_foot : Node3D

const ACCEL := 15.0
var speed := 3.0

#enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }
var move_dir : Utilities.DIRECTIONS = Utilities.DIRECTIONS.DOWN
@export var wall_check : RayCast3D
var death_dir : Utilities.DIRECTIONS
var last_attacker : CharacterBody3D
var target_square : Vector2

var spawn_hole : Node3D


func _ready() -> void:
	attack_collision.disabled = !multiplayer.is_server()


func spawn_finished() -> void:
	spawn_hole.close.rpc()
	characters.enemy_finished_spawning(Utilities.get_closest_egg_square(global_position))


func get_prev_state() -> String:
	return state_machine.prev_state.name.to_lower()


func _footstep(foot_down : bool) -> void:
	spawn_footprint.emit(self, foot_down)


func _body_attackable(character : CharacterBody3D) -> void:
	if character is Player:
		if state_machine.current_state.has_method("attack"):
			state_machine.current_state.attack()


func attacked(attacker : CharacterBody3D, attack_dir : int) -> void:
	last_attacker = attacker
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


func burn(emitter_id : int) -> void:
	last_attacker = characters.get_player_by_id(emitter_id)
	if state_machine.current_state.has_method("burn"):
		state_machine.current_state.burn()


func disable_collision() -> void:
	$Collision.call_deferred("set_disabled", true)


func pit_fall(pit_fall : Trap) -> void:
	# HAHA hack to avoid double respawn for now
	#collision.set_deferred("disabled", true)
	#pit_fall.close.rpc()
	
	if !pit_fall:
		push_error("Bad pit fall node path")
		return
	position = pit_fall.position
	state_machine.current_state.transition.emit(state_machine.current_state, "DeathAnimState")
	anim_player.play("Flail")
	await anim_player.animation_finished
	anim_player.play("PitFall")
	await anim_player.animation_finished
	#collision.set_deferred("disabled", true)
	pit_fall.close.rpc()
	die()


func die() -> void:
	if spawn_hole:
		spawn_hole.close.rpc()
	characters.enemy_defeated(self)
	queue_free()
