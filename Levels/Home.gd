extends MeshInstance3D


const SCORE_VALUE := 50000

var level : Node3D


func flash() -> void:
	visible = !visible


func player_entered(player : CharacterBody3D) -> void:
	if player is Player:
		Globals.add_to_score(SCORE_VALUE)
		level.level_complete()
