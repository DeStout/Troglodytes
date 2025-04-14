extends Node


@onready var game := get_tree().get_current_scene()

var score := 0


func reset_game() -> void:
	score = 0
	game.set_score(score)
	#game.set_lives(player_lives)
