extends State


func unfreeze() -> void:
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	transition.emit(self, "DeathState")


func burn() -> void:
	transition.emit(self, "BurnState")


#func enter() -> void: pass
#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
