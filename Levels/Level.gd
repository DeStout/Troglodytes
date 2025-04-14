class_name Level extends Node3D


var egg_ := load("res://PickUps/Egg.tscn")
var home_ := load("res://Levels/Props/Home.tscn")

var game : Node
@export var board : Node3D
@export var ui_score : Label
@export var ui_lives : Label
@export var characters : Node3D
@export var pick_ups : Node3D
@export var eggs : Node3D
@export var fx : Node3D
@export var play_area : Area3D

var free_squares : Array[Node3D] = []


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_set_up()


func _set_up() -> void:
	Globals.add_and_set_lives(0)
	Globals.add_and_set_score(0)
	
	#characters.player.game_over.connect(game_over)
	characters.player.freeze_pick_up.connect(characters.freeze_enemies)
	characters.player.spawn_footprint.connect(spawn_footprint)
	characters.player.spawn_fire_ball.connect(spawn_fire_ball)
	Utilities.anims_to_constant(characters.player)
	
	var used_squares : Array[Node3D] = []
	used_squares = characters.spawn_enemies(used_squares)
	used_squares = pick_ups.spawn_pick_ups(used_squares)
	_spawn_eggs(used_squares)


func _spawn_eggs(used_squares : Array[Node3D]) -> void:
	for square in get_tree().get_nodes_in_group("EggSquares"):
		if Utilities.v3_to_v2(square.global_position) == \
							Utilities.v3_to_v2(characters.player.global_position):
			continue
		if used_squares.has(square):
			continue
		var egg = egg_.instantiate()
		eggs.add_child(egg, true)
		egg.collected.connect(egg_collected)
		egg.position = square.global_position
		egg.position.y += 0.5


func set_square_free(square : Node3D) -> void:
	if !free_squares.has(square):
		free_squares.append(square)


func get_rand_free_square(use_square := true) -> Node3D:
	var free_square = free_squares.pick_random()
	if use_square:
		free_squares.erase(free_square)
	return free_square


func spawn_footprint(character : CharacterBody3D, foot_down : bool) -> void:
	fx.spawn_footprint(character, foot_down)


func spawn_fire_ball(player) -> void:
	fx.spawn_fire_ball(player)


func egg_collected(egg : Node3D) -> void:
	free_squares.append(Utilities.get_closest_egg_square(egg.global_position))
	if eggs.get_child_count() == 1:
		_spawn_home()


func _spawn_home() -> void:
	var home_squares := get_tree().get_nodes_in_group("HomeSquares")
	var home_square : Node3D = home_squares.pick_random()
	var home_pos : Vector3 = home_square.global_position
	
	for wall in board.walls.get_children():
		if Utilities.v3_to_v2(wall.global_position) == Utilities.v3_to_v2(home_pos):
			wall.queue_free()
			break
	var home : MeshInstance3D = home_.instantiate()
	add_child(home)
	home.level = self
	home.position = Vector3(home_pos.x, 0.5, home_pos.z)


func level_complete() -> void:
	Globals.add_and_set_lives(1)
	level_clean_up()
	game.load_next_level()


func level_clean_up() -> void:
	for connection in play_area.body_exited.get_connections():
		play_area.body_exited.disconnect(connection["callable"])
	board.level_complete_clean_up()
