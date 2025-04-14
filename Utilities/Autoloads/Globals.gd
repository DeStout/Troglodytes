extends Node


@onready var game := get_tree().get_current_scene()


func add_and_set_score(new_score : int) -> void:
	game.score += new_score
	game.level.ui_score.text = "Score: " + str(game.score)


func add_and_set_lives(new_lives : int) -> void:
	print(game.player_lives[0])
	game.player_lives[0] += new_lives
	print(game.player_lives[0],"\n")
	
	if game.player_lives[0] == -1:
		_reset_game()
		game.level.level_clean_up()
		game.start_new_game()
		
	game.level.ui_lives.text = "Lives: " + str(game.player_lives[0])


func _reset_game() -> void:
	game.score = 0
	game.player_lives[0] = game.INIT_LIVES
