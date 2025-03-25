extends State


@onready var freeze_timer := $FreezeTimer


func enter() -> void:
	freeze_timer.start()


func _unfreeze() -> void:
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	freeze_timer.stop()
	transition.emit(self, "DeathState")


func freeze() -> void:
	freeze_timer.start()


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
