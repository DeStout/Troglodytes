class_name SpawnState extends State


@export var anim_player : AnimationPlayer


func enter() -> void:
	if !multiplayer.is_server():
		return
	#print("Enter SpawnState")
	anim_player.animation_finished.connect(_spawn_finished)
	anim_player.play("Spawn")


func _spawn_finished(anim_finished : String) -> void:
	assert(anim_finished == "Spawn", "SpawnState and 'Spawn' animation desynced")
	character.spawn_finished()
	if anim_player.animation_finished.has_connections():
		anim_player.animation_finished.disconnect(_spawn_finished)
	transition.emit(self, "ThinkState")


func attacked() -> void:
	if anim_player.animation_finished.has_connections():
		anim_player.animation_finished.disconnect(_spawn_finished)
	anim_player.pause()
	transition.emit(self, "HitStunState")


func freeze() -> void:
	if anim_player.animation_finished.has_connections():
		anim_player.animation_finished.disconnect(_spawn_finished)
	anim_player.pause()
	transition.emit(self, "FreezeState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
