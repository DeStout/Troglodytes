class_name Trap extends Node3D


signal despawn

enum TYPES { PIT_FALL }
@export var effect : TYPES = -1
@export var despawn_timer : Timer
@export var despawn_range := Vector2(10.0, 15.0)
@export var collision : CollisionShape3D

var trap_trigger : Callable


func _body_triggered(body : CharacterBody3D) -> void:
	if multiplayer.is_server():
		despawn_timer.stop()
		trap_trigger.call(body)
		collision.call_deferred("set_disabled", true)


func _despawn() -> void:
	despawn.emit(self.position)
	queue_free()
