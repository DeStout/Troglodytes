extends Node


var level_ := load("res://Levels/Level.tscn")

@export var level : Node3D
@export var score_label : Label
@export var lives_label : Label


func set_score(new_score : int) -> void:
	score_label.text = "Score: " + str(new_score)


func set_lives(new_lives : int) -> void:
	lives_label.text = "Lives: " + str(new_lives)


func start_new_level() -> void:
	level.queue_free()
	
	var new_level : Node3D = level_.instantiate()
	new_level.world = self
	$LevelViewport/SubViewport.add_child(new_level, true)
	level = new_level
