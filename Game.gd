class_name Game extends Node


@export var main_menu : Control

@export var level_spawner : MultiplayerSpawner
var levels : Array[String] = [ "res://Levels/Level1a.tscn",
								"res://Levels/Level1b.tscn",
								"res://Levels/Level2a.tscn",
								"res://Levels/Level2b.tscn",
								"res://Levels/Level3a.tscn",
								"res://Levels/Level3b.tscn" ]
@export var level : Node3D
var level_num : int = 0


func _ready() -> void:
	ENetNetwork.game = self


func start_game() -> void:
	remove_child(main_menu)
	if !ENetNetwork.peers.size():
		ENetNetwork.add_local_peer()
	if multiplayer.is_server():
		start_new_game()


func start_new_game() -> void:
	if level:
		level_num = 0
		level.queue_free()
	
	level_spawner.spawn(level_num)
	#level_spawner.spawn(2)


func load_next_level() -> void:
	level.queue_free()
	level_num = min(levels.size() - 1, level_num + 1)
	await level.tree_exited
	level_spawner.spawn(level_num)
