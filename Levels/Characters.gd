@tool
extends Node3D


const MAX_ENEMIES := 5
const RESPAWN_DELAY := Vector2(2.0, 6.0)

var player_ := load("res://Player/Player.tscn")
var enemy_ := load("res://Enemies/Enemy.tscn")

@export var level : Node3D
@export var player : CharacterBody3D


func spawn_player(player_square : Node3D) -> void:
	player = player_.instantiate()
	add_child(player)
	player.owner = level
	player.position = player_square.global_position
	player.position.y = 0
	player.rotation.y = PI


func spawn_enemies(used_squares : Array[Node3D]) -> Array:
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for i in range(MAX_ENEMIES):
		var egg_square : Node3D = egg_squares.pick_random()
		while(player.global_position.distance_to(egg_square.global_position) < 3.0):
			egg_squares.erase(egg_square)
			egg_square = egg_squares.pick_random()
			
		var enemy = enemy_.instantiate()
		add_child(enemy, true)
		enemy.characters = self
		enemy.position = Vector3(egg_square.global_position.x, -2, \
														egg_square.global_position.z)
		enemy.rotation.y = PI
		
		egg_squares.erase(egg_square)
		used_squares.append(egg_square)
		level.set_square_free(egg_square)
		
	return used_squares


func clear_board() -> void:
	for character in get_children():
		character.free()


func _respawn_enemy() -> void:
		var enemy = enemy_.instantiate()
		var free_square : Node3D = level.get_rand_free_square()
		add_child(enemy, true)
		enemy.characters = self
		enemy.position = Vector3(free_square.global_position.x, -2, \
														free_square.global_position.z)
		enemy.rotation.y = PI


func enemy_finished_spawning(spawn_square : Node3D) -> void:
	level.set_square_free(spawn_square)


func enemy_defeated(enemy : Enemy) -> void:
	await get_tree().create_timer(randf_range(RESPAWN_DELAY.x, RESPAWN_DELAY.y)).timeout
	_respawn_enemy()


func character_exited(character : CharacterBody3D) -> void:
	if character is Player:
		player.respawn()
	elif character is Enemy:
		if character.state_machine.current_state is DeathState:
			return
		character.die()
