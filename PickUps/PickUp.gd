class_name PickUp extends Node3D


signal despawn

const SCORE_VALUE := 50

enum EFFECTS { SPEED_UP, SLOW_DOWN, FIRE_POWER, FREEZE, INVINCIBLE, PINEAPPLE }
@export var effect : EFFECTS = -1
@export var mesh : Node3D = null
@export var sfx : AudioStreamPlayer
@export var collision : CollisionShape3D

const DESPAWN_RANGE := Vector2(9.0, 14.0)
@export var despawn_timer : Timer

var apply_effect : Callable


func _ready() -> void:
	_set_type()
	collision.set_deferred("disabled", !multiplayer.is_server())
	if multiplayer.is_server():
		despawn_timer.start(randf_range(DESPAWN_RANGE.x, DESPAWN_RANGE.y))


func _set_type() -> void:
	match effect:
		#EFFECTS.SPEED_UP:
			#apply_effect = _effect_speed.bind(0.5)
		#EFFECTS.SLOW_DOWN:
			#apply_effect = _effect_speed.bind(-0.5)
		EFFECTS.FIRE_POWER:
			apply_effect = _give_fire_power
		#EFFECTS.FREEZE:
			#apply_effect = _apply_freeze
		EFFECTS.INVINCIBLE:
			apply_effect = _set_invincible
		EFFECTS.PINEAPPLE:
			pass
		_:
			pass


func _collected(body : CharacterBody3D) -> void:
	if body is Player and multiplayer.is_server():
		despawn_timer.stop()
		_pick_up.rpc()
		apply_effect.call(body)
		collision.call_deferred("set_disabled", true)
		if sfx:
			await sfx.finished
		_despawn()


@rpc("authority", "call_local")
func _pick_up() -> void:
	mesh.visible = false
	sfx.play()


func _effect_speed(player : Player, speed_affect : float) -> void:
	player.effect_speed.rpc_id(player.get_multiplayer_authority(), speed_affect)


func _give_fire_power(player : Player) -> void:
	player.give_fire_power.rpc()


func _apply_freeze(player : Player) -> void:
	player.apply_freeze()


func _set_invincible(player : Player) -> void:
	player.set_invincible.rpc()


func _despawn() -> void:
	despawn.emit(self)
	queue_free()
