class_name SpawnState extends State


var tween : Tween


func enter() -> void:
	#print("Enter SpawnState")
	if tween:
		tween.play()
	else:
		tween = create_tween()
		tween.tween_property(character, "position:y", 0, 1.0)
	await tween.finished
	character.spawn_finished()
	transition.emit(self, "ThinkState")


func attacked() -> void:
	tween.pause()
	transition.emit(self, "HitStunState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
