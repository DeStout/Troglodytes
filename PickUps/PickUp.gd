class_name PickUp extends Node3D


signal despawn

const SCORE_VALUE := 50

var speed_up_ := load("res://PickUps/FastArrow.tscn")
var slow_down_ := load("res://PickUps/SlowArrow.tscn")

enum EFFECTS { SPEED_UP, SLOW_DOWN, FIRE_POWER, FREEZE, INVINCIBLE, PINEAPPLE }
var effect : int : set = _set_type
var mesh : Node3D = null

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
			pass
		EFFECTS.FREEZE:
			var cube := MeshInstance3D.new()
			cube.mesh = BoxMesh.new()
			cube.mesh.size = Vector3(0.8, 0.8, 0.8)
			var mat = load("res://Player/PlayerMat.tres")
			cube.set_surface_override_material(0, mat)
			_add_mesh(cube)
			cube.position.y = 1.0
		EFFECTS.INVINCIBLE:
			pass
		EFFECTS.PINEAPPLE:
			pass


func _add_mesh(new_mesh : Node3D) -> void:
	add_child(new_mesh)
	mesh = new_mesh


func _collected(body : CharacterBody3D) -> void:
	if body is Player:
		Globals.add_to_score(SCORE_VALUE)
		_apply_effect(body)
		_despawn()


func _apply_effect(player : Player) -> void:
	match effect:
		EFFECTS.SPEED_UP:
			player.effect_speed(0.5)
		EFFECTS.SLOW_DOWN:
			player.effect_speed(-0.5)
		EFFECTS.FIRE_POWER:
			pass
		EFFECTS.FREEZE:
			player.apply_freeze()
		EFFECTS.INVINCIBLE:
			pass
		EFFECTS.PINEAPPLE:
			pass


func _despawn() -> void:
	despawn.emit(self)
	queue_free()
