extends MeshInstance3D


const SCORE_VALUE := 50000

var level : Node3D
@export var timer : Timer
@export var spawn_sfx : AudioStreamPlayer


func flash() -> void:
	visible = !visible
	if visible:
		timer.start(1.0)
	else:
		timer.start(0.25)


func player_entered(player : CharacterBody3D) -> void:
	if player is Player:
		level.level_complete()
