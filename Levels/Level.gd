class_name Level extends Node3D


var home_ := load("res://Levels/Props/Home.tscn")

var game : Node
@export var board : MultiplayerSpawner
@export var camera : Camera3D
@export var characters : MultiplayerSpawner
@export var pick_ups : MultiplayerSpawner
@export var traps : MultiplayerSpawner
@export var eggs : MultiplayerSpawner
@export var fx : MultiplayerSpawner
@export var play_area : Area3D
@export var home_spawner : MultiplayerSpawner

@export var player_uis : HBoxContainer
@export var ui_player_names : Array[Label]
@export var ui_player_scores : Array[Label]
@export var ui_player_lives : Array[HBoxContainer]

var free_squares : Array[Node3D] = []
var num_eggs : int


func _ready() -> void:
	Pause.update()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if multiplayer.is_server():
		_set_up()
		#_spawn_home()


func _set_up() -> void:
	var used_squares : Array[Node3D] = []
	
	characters.spawn_players()
	_connect_player_signals()
	_create_player_UIs()
	await get_tree().physics_frame
	
	used_squares = characters.spawn_enemies(used_squares)
	used_squares = pick_ups.spawn_pick_ups(used_squares)
	traps.spawn_traps()
	_spawn_eggs(used_squares)


func _connect_player_signals() -> void:
	for player in characters.players:
		player.add_score.connect(characters._add_to_score)
		player.delta_life.connect(characters._add_subtract_life)
		player.freeze_pick_up.connect(characters.freeze_enemies)
		player.freeze_pick_up.connect(board.freeze_spawn_holes)
		player.spawn_footprint.connect(spawn_footprint)
		player.spawn_fire_ball.connect(spawn_fire_ball)
		Utilities.anims_to_constant(player)
		
		if player.is_multiplayer_authority():
			camera.set_player(player)


func _create_player_UIs() -> void:
	for player_id in ENetNetwork.peers.keys():
		var player_num := ENetNetwork.get_player_number(player_id)
		player_uis.get_children()[player_num].visible = true
		ui_player_names[player_num].text = ENetNetwork.peers[player_id]["name"]
		ui_player_scores[player_num].text = "%012d" % 0


func _spawn_eggs(used_squares : Array[Node3D]) -> void:
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for square in egg_squares:
		if used_squares.has(square) or square.is_in_group("PlayerSquares"):
			continue
		var egg = eggs.spawn(square.global_position + Vector3(0, 0.5, 0))
		egg.collected.connect(egg_collected)
	num_eggs = eggs.get_children().size()


func set_start_player_stats(player_stats : Dictionary) -> void:
	characters.player_stats = player_stats
	for player_id in player_stats.keys():
		set_ui_score(player_id, player_stats[player_id]["score"])
		set_ui_lives(player_id, player_stats[player_id]["lives"])


func set_square_free(square : Node3D) -> void:
	if !free_squares.has(square):
		free_squares.append(square)


func has_free_square() -> bool:
	return bool(free_squares.size())


func get_rand_free_square(use_square := true) -> Node3D:
	if !free_squares.size():
		breakpoint
	var free_square = free_squares.pick_random()
	if use_square:
		free_squares.erase(free_square)
	return free_square


func set_ui_score(player_id : int, score_value : int) -> void:
	var score_text = "%012d" % score_value
	ui_player_scores[ENetNetwork.get_player_number(player_id)].text = score_text


func set_ui_lives(player_id : int, lives_amount : int) -> void:
	var player_num = ENetNetwork.get_player_number(player_id)
	var ui_lives := ui_player_lives[player_num].get_children()
	for life_num in range(ui_lives.size()):
		var life_ui = ui_lives[life_num]
		life_ui.visible = true if life_num + 1 < lives_amount else false


func spawn_footprint(character : CharacterBody3D, foot_down : bool) -> void:
	fx.spawn_footprint(character, foot_down)


func spawn_fire_ball(player) -> void:
	fx.spawn_fire_ball(player)


func egg_collected(egg : Node3D) -> void:
	num_eggs -= 1
	free_squares.append(Utilities.get_closest_egg_square(egg.global_position))
	if !num_eggs:
		_spawn_home()


func _spawn_home() -> void:
	if !multiplayer.is_server():
		return
	
	# Keep home_num for multiplayer synchronization
	var home_num := randi_range(0, get_tree().get_nodes_in_group("HomeSquares").size()-1)
	home_spawner.spawn(home_num)


func level_complete() -> void:
	level_clean_up()
	game.load_next_level(characters.player_stats)


func level_clean_up() -> void:
	for connection in play_area.body_exited.get_connections():
		play_area.body_exited.disconnect(connection["callable"])
	board.level_complete_clean_up()


func game_over() -> void:
	game.quit_to_main()
