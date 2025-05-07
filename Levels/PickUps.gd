extends MultiplayerSpawner


var pick_up_ := load("res://PickUps/PickUp.tscn")

enum PICK_UPS {SPEED_UP, SLOW_DOWN, FIRE_POWER, FREEZE, INVINCIBLE, PINEAPPLE}
const RESPAWN_DELAY := Vector2(1.0, 5.0)

@export var level : Node3D
@export var num_pick_ups := 4
@export var level_pick_ups : Array[PICK_UPS]


func _ready() -> void:
	spawn_function = _spawn_pick_up


func _spawn_pick_up(data : Dictionary) -> PickUp:
		var pick_up : Node3D = pick_up_.instantiate()
		pick_up.global_position = Vector3(data["position"].x, 0, data["position"].z)
		pick_up.set_type(data["type"])
		if multiplayer.is_server():
			pick_up.despawn.connect(_pick_up_despawned)
		return pick_up


func spawn_pick_ups(used_squares : Array[Node3D]) -> Array:
	if level_pick_ups.size() == 0:
		printerr("No pick ups defined for ", level.name)
		return used_squares
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for square in used_squares:
		egg_squares.erase(square)
	for i in range(num_pick_ups):
		var egg_square : Node3D = egg_squares.pick_random()
		if _any_player_within_dist(egg_square.global_position, 1.0):
			egg_squares.erase(egg_square)
			egg_square = egg_squares.pick_random()
		
		spawn({"position" : egg_square.global_position, "type" : level_pick_ups.pick_random()})
		
		egg_squares.erase(egg_square)
		used_squares.append(egg_square)
	return used_squares


func _pick_up_despawned(pick_up : PickUp) -> void:
	level.set_square_free(Utilities.get_closest_egg_square(pick_up.global_position))
	await get_tree().create_timer(randf_range(RESPAWN_DELAY.x, RESPAWN_DELAY.y)).timeout
	
	var spawn_pos = level.get_rand_free_square().global_position
	spawn({"position" : spawn_pos, "type" : level_pick_ups.pick_random()})


func _any_player_within_dist(check_to : Vector3, min_dist : float) -> bool:
	for player in level.characters.players:
		if player.global_position.distance_to(check_to) < min_dist:
			return true
	return false
