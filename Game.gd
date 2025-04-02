extends Node


@export var main_menu : Control

var levels : Array[String] = [ "res://Levels/Level1.tscn",
								"res://Levels/Level2.tscn",
								"res://Levels/Level3.tscn" ]
@export var level : Node3D
var level_num : int = 0
@export var score_label : Label
@export var lives_label : Label


func set_score(new_score : int) -> void:
	score_label.text = "Score: " + str(new_score)


func set_lives(new_lives : int) -> void:
	lives_label.text = "Lives: " + str(new_lives)


func start_game() -> void:
	remove_child(main_menu)
	start_new_game()


func start_new_game() -> void:
	if level:
		level.queue_free()
	
	var new_level : Node3D = load(levels[0]).instantiate()
	new_level.game = self
	add_child(new_level, true)
	level = new_level
	$UIBoard1.visible = true


func load_next_level() -> void:
	level.queue_free()
	level_num = min(levels.size() - 1, level_num + 1)
	
	var new_level : Node3D = load(levels[level_num]).instantiate()
	new_level.game = self
	add_child(new_level, true)
	level = new_level
	$UIBoard1.visible = true
