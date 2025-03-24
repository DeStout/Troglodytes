extends Node


var level_ := load("res://Levels/Level2.tscn")

@export var main_menu : Control

@export var level : Node3D
@export var score_label : Label
@export var lives_label : Label


func set_score(new_score : int) -> void:
	score_label.text = "Score: " + str(new_score)


func set_lives(new_lives : int) -> void:
	lives_label.text = "Lives: " + str(new_lives)


func start_new_level() -> void:
	if level:
		level.queue_free()
	
	var new_level : Node3D = level_.instantiate()
	new_level.game = self
	add_child(new_level, true)
	level = new_level
	$UIBoard1.visible = true


func start_game() -> void:
	remove_child(main_menu)
	start_new_level()
