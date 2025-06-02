class_name SpawnHole extends Node3D


signal open_finished

var closing := false
@export var anim_player : AnimationPlayer


func _spawn_enemy() -> void:
	if closing:
		return
	closing = true
	anim_player.speed_scale = 2.0
	
	if multiplayer.is_server():
		open_finished.emit()


func freeze() -> void:
	anim_player.pause()


func unfreeze() -> void:
	anim_player.play()


@rpc("authority", "call_local")
func close() -> void:
	print(multiplayer.get_unique_id())
	anim_player.play_backwards("OpenClose")
	
	if multiplayer.is_server():
		await anim_player.animation_finished
		queue_free()
