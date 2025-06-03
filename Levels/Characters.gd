extends MultiplayerSpawner


const INIT_LIVES := 3
const MAX_LIVES := 4
const RESPAWN_DELAY := Vector2(2.0, 6.0)

var player_ := load("res://Player/Player.tscn")
var player_mat_ := load("res://Player/PlayerSkin_Mat.tres")
var enemy_ := load("res://Enemies/Enemy.tscn")

@export var level : Node3D
@export var board : MultiplayerSpawner
@export var players : Array[Player]
@export var num_enemies := 5
var enemies : Array[Enemy]
var respawn_tweens : Array[Tween]

var freeze_time := 0.0
@export var unfreeze_sfx : AudioStreamPlayer


func _ready() -> void:
	ENetNetwork.peer_disconnected.connect(_player_disconnected)
	spawn_function = _spawn_player


func _process(delta: float) -> void:
	if freeze_time:
		freeze_time = max(freeze_time - delta, 0.0)
		if freeze_time == 0.0:
			_unfreeze_enemies()


func _spawn_player(player_num : int) -> Player:
	var player = player_.instantiate()
	player.set_multiplayer_authority(ENetNetwork.peers.keys()[player_num])
	var spawn_square = get_tree().get_nodes_in_group("PlayerSquares")[player_num]
	player.position = spawn_square.global_position
	player.rotation = spawn_square.rotation
	player.move_dir = Utilities.get_move_dir(Vector2(player.basis.z.x, -player.basis.z.z))
	players.append(player)
	if player_num > 0:
		_set_player_texture(player, player_num)
	
	return player


func _set_player_texture(player : Player, player_num : int) -> void:
	var player_tex : CompressedTexture2D
	match player_num:
		1:
			player_tex = load("res://Player/Player2_A.png")
		2:
			player_tex = load("res://Player/Player3_A.png")
		3:
			player_tex = load("res://Player/Player4_A.png")
		_:
			player_tex = load("res://Player/Player1_A.png")
	player.player_mat.albedo_texture = player_tex


# Do not type cast function parameter
func _spawn_enemy(spawn_hole) -> Enemy:
	var enemy : Enemy = enemy_.instantiate()
	Utilities.anims_to_constant(enemy)
	if multiplayer.is_server():
		enemy.spawn_hole = spawn_hole
		enemy.position = spawn_hole.global_position
	enemy.spawn_footprint.connect(level.spawn_footprint)
	enemies.append(enemy)
	enemy.characters = self
	enemy.rotation.y = PI
	return enemy


func spawn_players() -> void:
	spawn_function = _spawn_player
	
	var player_squares := get_tree().get_nodes_in_group("PlayerSquares")
	for square_i in range(0, player_squares.size()):
		if square_i + 1 <= ENetNetwork.peers.size():
			var player = spawn(square_i)
			#if square_i > 0:
				#_set_player_texture.rpc(square_i)
			continue
		player_squares[square_i].remove_from_group("PlayerSquares")


func _player_disconnected(peer_id : int) -> void:
	for player in players:
		if player.get_multiplayer_authority() == peer_id:
			players.erase(player)
			player.queue_free()
			break


func spawn_enemies(used_squares : Array[Node3D]) -> Array:
	spawn_function = _spawn_enemy
	
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for i in range(num_enemies):
		var egg_square : Node3D = egg_squares.pick_random()
		while(_any_player_within_dist(egg_square.global_position, 3.0)):
			egg_squares.erase(egg_square)
			egg_square = egg_squares.pick_random()
		
		board.spawn(egg_square.global_position)
		
		egg_squares.erase(egg_square)
		used_squares.append(egg_square)
		level.set_square_free(egg_square)
		
	return used_squares


func _respawn_enemy() -> void:
		var free_square : Node3D = level.get_rand_free_square()
		var spawn_pos := Vector3(free_square.global_position.x, 0, \
														free_square.global_position.z)
		while(_any_player_within_dist(spawn_pos, 1.5)):
			free_square = level.get_rand_free_square()
			spawn_pos = Vector3(free_square.global_position.x, 0, \
														free_square.global_position.z)
		
		board.spawn(free_square.global_position)


func enemy_finished_spawning(spawn_square : Node3D) -> void:
	level.set_square_free(spawn_square)


func _any_player_within_dist(check_to : Vector3, min_dist : float) -> bool:
	for player in players:
		if player.global_position.distance_to(check_to) < min_dist:
			return true
	return false


func freeze_enemies() -> void:
	freeze_time = 5.0
	for tween in respawn_tweens:
		tween.pause()
	for enemy in enemies:
		enemy.freeze()
	# player signals directly to Board to freeze spawn holes


func _unfreeze_enemies() -> void:
	_unfreeze_sfx.rpc()
	await unfreeze_sfx.finished
	if freeze_time:
		return
	for tween in respawn_tweens:
		tween.play()
	for enemy in enemies:
		enemy.unfreeze()
	board.unfreeze_spawn_holes()


@rpc("authority", "call_local")
func _unfreeze_sfx() -> void:
	unfreeze_sfx.play()


func enemy_defeated(enemy : Enemy) -> void:
	enemies.erase(enemy)
	if multiplayer.is_server():
		var tween = create_tween()
		respawn_tweens.append(tween)
		tween.tween_interval(randf_range(RESPAWN_DELAY.x, RESPAWN_DELAY.y))
		if freeze_time:
			tween.pause()
		await tween.finished
		respawn_tweens.erase(tween)
		_respawn_enemy()


func character_exited(character : CharacterBody3D) -> void:
	if multiplayer.is_server():
		var player_id := character.get_multiplayer_authority()
		if character is Player and ENetNetwork.peers.has(player_id):
			character.exit_stage.rpc_id(player_id)
		elif character is Enemy:
			var current_state = character.state_machine.current_state
			if current_state is DeathState or current_state is BurnState:
				return
			character.die()
