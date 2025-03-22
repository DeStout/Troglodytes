class_name PickUp extends Node3D


signal despawn

var fast_ := load("res://PickUps/FastArrow.tscn")
var slow_ := load("res://PickUps/SlowArrow.tscn")

enum EFFECTS { FAST, SLOW }
var effect : int : set = _set_type
var mesh : Node3D = null

const DESPAWN_RANGE := Vector2(9.0, 14.0)
@export var despawn_timer : Timer


func _ready() -> void:
	despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _set_type(new_effect) -> void:
	effect = new_effect
	match effect:
		EFFECTS.FAST:
			_add_mesh(fast_.instantiate())
		EFFECTS.SLOW:
			_add_mesh(slow_.instantiate())


func _add_mesh(new_mesh : Node3D) -> void:
	add_child(new_mesh)
	mesh = new_mesh


func _collected(body : CharacterBody3D) -> void:
	if body is Player:
		_apply_effect(body)
		_despawn()


func _apply_effect(player : Player) -> void:
	match effect:
		EFFECTS.FAST:
			player.effect_speed(0.5)
		EFFECTS.SLOW:
			player.effect_speed(-0.5)


func _despawn() -> void:
	despawn.emit(self)
	queue_free()
