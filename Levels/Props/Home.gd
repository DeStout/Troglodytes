extends Node3D


const SCORE_VALUE := 25000

var level : Node3D
@export var mesh : MeshInstance3D
@export var timer : Timer
@export var spawn_sfx : AudioStreamPlayer


func flash() -> void:
	mesh.visible = !mesh.visible
	if mesh.visible:
		timer.start(1.0)
	else:
		timer.start(0.25)


func player_entered(player : CharacterBody3D) -> void:
	if player is Player:
		player.give_score(SCORE_VALUE)
		level.level_complete()
