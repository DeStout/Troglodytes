class_name Game extends Node


@export var main_menu : Control

var levels : Array[String] = [ "res://Levels/Level1a.tscn",
								"res://Levels/Level1b.tscn",
								"res://Levels/Level2a.tscn",
								"res://Levels/Level2b.tscn",
								"res://Levels/Level3a.tscn",
								"res://Levels/Level3b.tscn" ]
@export var level : Node3D
var level_num : int = 0

const INIT_LIVES := 2
const MAX_LIVES := 4

var score := 0
var player_lives : Array[int] = [INIT_LIVES]


func start_game() -> void:
	remove_child(main_menu)
	start_new_game()


func start_new_game() -> void:
	if level:
		level_num = 0
		level.queue_free()
	
	var new_level : Node3D = load(levels[level_num]).instantiate()
	#var new_level : Node3D = load(levels[4]).instantiate()
	new_level.game = self
	add_child(new_level, true)
	level = new_level


func load_next_level() -> void:
	level.queue_free()
	level_num = min(levels.size() - 1, level_num + 1)
	
	var new_level : Node3D = load(levels[level_num]).instantiate()
	new_level.game = self
	add_child(new_level, true)
	level = new_level
