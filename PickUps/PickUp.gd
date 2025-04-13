class_name PickUp extends Node3D


signal despawn

const SCORE_VALUE := 50

var speed_up_ := load("res://PickUps/FastArrow.tscn")
var slow_down_ := load("res://PickUps/SlowArrow.tscn")

enum EFFECTS { SPEED_UP, SLOW_DOWN, FIRE_POWER, FREEZE, INVINCIBLE, PINEAPPLE }
var effect : int : set = _set_type
var mesh : Node3D = null
@export var collision : CollisionShape3D

@export var speed_up_sfx : AudioStreamPlayer
@export var slow_down_sfx : AudioStreamPlayer
@export var freeze_sfx : AudioStreamPlayer
@export var fire_sfx : AudioStreamPlayer
@export var inv_sfx : AudioStreamPlayer

const DESPAWN_RANGE := Vector2(9.0, 14.0)
@export var despawn_timer : Timer


func _ready() -> void:
	despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _set_type(new_effect) -> void:
	effect = new_effect
	match effect:
		EFFECTS.SPEED_UP:
			_add_mesh(speed_up_.instantiate())
		EFFECTS.SLOW_DOWN:
			_add_mesh(slow_down_.instantiate())
		EFFECTS.FIRE_POWER:
			var cube := MeshInstance3D.new()
			cube.mesh = BoxMesh.new()
			cube.mesh.size = Vector3(0.8, 0.25, 0.25)
			var mat = load("res://Enemies/EnemyMat.tres")
			cube.set_surface_override_material(0, mat)
			_add_mesh(cube)
			cube.position.y = 1.0
		EFFECTS.FREEZE:
			var cube := MeshInstance3D.new()
			cube.mesh = BoxMesh.new()
			cube.mesh.size = Vector3(0.8, 0.8, 0.8)
			var mat = load("res://Player/PlayerMat.tres")
			cube.set_surface_override_material(0, mat)
			_add_mesh(cube)
			cube.position.y = 1.0
		EFFECTS.INVINCIBLE:
			var halo := MeshInstance3D.new()
			halo.mesh = TorusMesh.new()
			halo.mesh.inner_radius = 0.3
			halo.mesh.outer_radius = 0.42
			halo.mesh.rings = 12
			halo.mesh.ring_segments = 5
			halo.transparency = 0.5
			var mat = load("res://Player/Halo_Mat.tres")
			halo.set_surface_override_material(0, mat)
			halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_add_mesh(halo)
			halo.position.y = 0.5
			halo.rotation_degrees.z = 0
			var light := OmniLight3D.new()
			light.omni_range = 0.75
			halo.add_child(light)
		EFFECTS.PINEAPPLE:
			pass


func _add_mesh(new_mesh : Node3D) -> void:
	add_child(new_mesh)
	mesh = new_mesh


func _collected(body : CharacterBody3D) -> void:
	if body is Player:
		Globals.add_to_score(SCORE_VALUE)
		var sfx := _apply_effect(body)
		mesh.visible = false
		collision.call_deferred("set_disabled", true)
		if sfx:
			await sfx.finished
		_despawn()


func _apply_effect(player : Player) -> AudioStreamPlayer:
	var sfx : AudioStreamPlayer
	match effect:
		EFFECTS.SPEED_UP:
			sfx = speed_up_sfx
			player.effect_speed(0.5)
		EFFECTS.SLOW_DOWN:
			sfx = slow_down_sfx
			player.effect_speed(-0.5)
		EFFECTS.FIRE_POWER:
			sfx = fire_sfx
			player.give_fire_power()
		EFFECTS.FREEZE:
			sfx = freeze_sfx
			player.apply_freeze()
		EFFECTS.INVINCIBLE:
			sfx = inv_sfx
			player.set_invincible()
		EFFECTS.PINEAPPLE:
			pass
	if sfx:
		sfx.play()
	return sfx


func _despawn() -> void:
	despawn.emit(self)
	queue_free()
