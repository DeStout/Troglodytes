extends MeshInstance3D


const SCORE_VALUE := 50000

var level : Node3D
@export var timer : Timer


func flash() -> void:
	visible = !visible
	if visible:
		timer.start(1.0)
	else:
		timer.start(0.25)


func player_entered(player : CharacterBody3D) -> void:
	if player is Player:
		Globals.add_to_score(SCORE_VALUE)
		level.level_complete()
