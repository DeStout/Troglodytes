extends Node


var score := 0


func add_to_score(points : int) -> void:
	score += points
	#print("Score: ", score)


func reset_score() -> void:
	score = 0
	print("Score: ", score)
