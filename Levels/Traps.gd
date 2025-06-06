extends MultiplayerSpawner


enum TRAPS { PIT_FALL }
var traps : Dictionary[TRAPS, Variant] = { 
								TRAPS.PIT_FALL : load("res://Traps/PitFall.tscn") }

@export var level : Node3D
@export var num_traps := 3
@export var respawn_delay := Vector2(3.0, 7.0)
@export var level_traps : Array[TRAPS]


func _ready() -> void:
	spawn_function = _spawn_trap


func _spawn_trap(data : Dictionary) -> Trap:
		var trap : Trap = traps[data["type"]].instantiate()
		var new_pos := Vector3(data["position"].x, 0, data["position"].z)
		trap.position = new_pos
		if multiplayer.is_server():
			trap.despawn.connect(_trap_despawned)
		return trap


func spawn_traps() -> void:
	for i in range(num_traps):
		var egg_square : Node3D = level.get_rand_free_square()
		while !egg_square:
			await get_tree().create_timer(0.5).timeout
			egg_square = level.get_rand_free_square()
		var trap_data := { "position" : egg_square.position, 
												"type" : level_traps.pick_random() }
		var spawn_timer := get_tree().create_timer(\
									randf_range(respawn_delay.x, respawn_delay.y))
		spawn_timer.timeout.connect(spawn.bind(trap_data))


func _trap_despawned(trap_pos : Vector3) -> void:
	level.set_square_free(Utilities.get_closest_egg_square(trap_pos))
	await get_tree().create_timer(randf_range(respawn_delay.x, respawn_delay.y)).timeout
	
	var egg_square : Node3D = level.get_rand_free_square()
	while !egg_square:
		await get_tree().create_timer(0.5).timeout
		egg_square = level.get_rand_free_square()
	spawn({"position" : egg_square.position, "type" : level_traps.pick_random()})


func _any_player_within_dist(check_to : Vector3, min_dist : float) -> bool:
	for player in level.characters.players:
		if player.global_position.distance_to(check_to) < min_dist:
			return true
	return false
