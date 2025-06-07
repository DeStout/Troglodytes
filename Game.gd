class_name Game extends Node


@export var set_window_positions := true
@export var show_on_main_screen := true


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
	SetWindowPos.set_window_positions(set_window_positions, show_on_main_screen)
	
	ENetNetwork.game = self
	Pause.game = self


func start_game() -> void:
	ENetNetwork.server_disconnected.connect(_server_disconnected)
	remove_child(main_menu)
	if !ENetNetwork.peers.size():
		ENetNetwork.add_local_peer()
	if multiplayer.is_server():
		start_new_game()


func start_new_game() -> void:
	level_num = 1
	level = level_spawner.spawn(level_num)


func load_next_level() -> void:
	level.queue_free()
	level_num = min(levels.size() - 1, level_num + 1)
	await level.tree_exited
	level_spawner.spawn(level_num)


func _server_disconnected() -> void:
	ENetNetwork.server_disconnected.disconnect(_server_disconnected)
	ENetNetwork.reset_peer()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Pause.visible = false
	get_tree().paused = false
	
	quit_to_main()


func quit_to_lobby() -> void:
	main_menu.options_menu.update()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Pause.visible = false
	get_tree().paused = false
	
	ENetNetwork.server_disconnected.disconnect(_server_disconnected)
	level.visible = false
	if multiplayer.is_server() and level:
		level.queue_free()
	level_num = 0
	
	add_child(main_menu)
	main_menu.mult_menu.lobby_menu.ready_button.button_pressed = false


func quit_to_main() -> void:
	main_menu.options_menu.update()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Pause.visible = false
	get_tree().paused = false
	
	ENetNetwork.server_disconnected.disconnect(_server_disconnected)
	if level:
		level.queue_free()
	level_num = 0
	ENetNetwork.reset_peer()
	
	add_child(main_menu)
	main_menu.mult_menu.back_button()
	main_menu.mult_menu.visible = false
	main_menu.main_menu.visible = true
