extends Node3D


const RESPAWN_DELAY := Vector2(2.0, 6.0)

var player_ := load("res://Player/Player.tscn")
var enemy_ := load("res://Enemies/Enemy.tscn")
var spawn_hole_ := load("res://Levels/SpawnHole.tscn")

@export var level : Node3D
@export var ground : CSGMesh3D
@export var player : CharacterBody3D
@export var num_enemies := 5
var enemies : Array[Enemy]
var respawn_tweens : Array[Tween]

var freeze_time := 0.0
@export var unfreeze_sfx : AudioStreamPlayer


func _process(delta: float) -> void:
	if freeze_time:
		freeze_time = max(freeze_time - delta, 0.0)
		if freeze_time == 0.0:
			_unfreeze_enemies()


func spawn_enemies(used_squares : Array[Node3D]) -> Array:
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for i in range(num_enemies):
		var egg_square : Node3D = egg_squares.pick_random()
		while(player.global_position.distance_to(egg_square.global_position) < 3.0):
			egg_squares.erase(egg_square)
			egg_square = egg_squares.pick_random()
			
		var enemy = enemy_.instantiate()
		var spawn_hole = spawn_hole_.instantiate()
		var spawn_pos = Vector3(egg_square.global_position.x, -2, \
														egg_square.global_position.z)
		enemy.position = spawn_pos
		spawn_hole.position = Vector3(spawn_pos.x, -0.8, spawn_pos.z)
		add_child(enemy, true)
		ground.add_child(spawn_hole, true)
		enemies.append(enemy)
		enemy.characters = self
		enemy.rotation.y = PI
		
		egg_squares.erase(egg_square)
		used_squares.append(egg_square)
		level.set_square_free(egg_square)
		
	return used_squares


func _respawn_enemy() -> void:
		var enemy = enemy_.instantiate()
		var spawn_hole = spawn_hole_.instantiate()
		var free_square : Node3D = level.get_rand_free_square()
		var spawn_pos := Vector3(free_square.global_position.x, -2, \
														free_square.global_position.z)
		enemy.position = spawn_pos
		spawn_hole.position = Vector3(spawn_pos.x, -0.8, spawn_pos.z)
		add_child(enemy, true)
		ground.add_child(spawn_hole, true)
		enemies.append(enemy)
		enemy.characters = self
		enemy.rotation.y = PI


func enemy_finished_spawning(spawn_square : Node3D) -> void:
	level.set_square_free(spawn_square)


func freeze_enemies() -> void:
	freeze_time = 5.0
	for tween in respawn_tweens:
		tween.pause()
	for enemy in enemies:
		enemy.freeze()


func _unfreeze_enemies() -> void:
	unfreeze_sfx.play()
	await unfreeze_sfx.finished
	if freeze_time:
		return
	for tween in respawn_tweens:
		tween.play()
	for enemy in enemies:
		enemy.unfreeze()
	


func enemy_defeated(enemy : Enemy) -> void:
	enemies.erase(enemy)
	var tween = create_tween()
	respawn_tweens.append(tween)
	tween.tween_interval(randf_range(RESPAWN_DELAY.x, RESPAWN_DELAY.y))
	if freeze_time:
		tween.pause()
	await tween.finished
	respawn_tweens.erase(tween)
	_respawn_enemy()


func character_exited(character : CharacterBody3D) -> void:
	if character is Player:
		player.respawn()
	elif character is Enemy:
		if character.state_machine.current_state is DeathState:
			return
		character.die()
