extends Node


const INIT_PLAYER_LIVES := 2

@onready var game := get_tree().get_current_scene()

var score := 0
var player_lives := INIT_PLAYER_LIVES


func add_to_score(points : int) -> void:
	score += points
	game.set_score(score)


func add_to_player_lives(lives : int) -> void:
	player_lives = clamp(player_lives + lives, 0, 3)
	game.set_lives(player_lives)


func reset_game() -> void:
	score = 0
	player_lives = INIT_PLAYER_LIVES
	game.set_score(score)
	game.set_lives(player_lives)
