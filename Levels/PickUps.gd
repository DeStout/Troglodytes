extends Node3D


var pick_up_ := load("res://PickUps/PickUp.tscn")

enum PICK_UPS {SPEED_UP, SLOW_DOWN, FIRE_POWER, FREEZE, INVINCIBLE, PINEAPPLE}
const MAX_PICK_UPS := 4
const RESPAWN_DELAY := Vector2(1.0, 5.0)

@export var level : Node3D
@export var level_pick_ups : Array[PICK_UPS]


func spawn_pick_ups(used_squares : Array[Node3D]) -> Array:
	if level_pick_ups.size() == 0:
		printerr("No pick ups defined for ", level.name)
		return used_squares
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")
	for square in used_squares:
		egg_squares.erase(square)
	for i in range(MAX_PICK_UPS):
		var egg_square : Node3D = egg_squares.pick_random()
		if egg_square.global_position.distance_to(\
									level.characters.player.global_position) < 1.0:
			egg_squares.erase(egg_square)
			egg_square = egg_squares.pick_random()
		
		var pick_up : Node3D = pick_up_.instantiate()
		pick_up.effect = level_pick_ups.pick_random()
		add_child(pick_up, true)
		pick_up.global_position = Vector3(egg_square.global_position.x, 0, \
													egg_square.global_position.z)
		pick_up.despawn.connect(_pick_up_despawned)
		egg_squares.erase(egg_square)
		used_squares.append(egg_square)
	return used_squares


func _pick_up_despawned(pick_up : PickUp) -> void:
	level.set_square_free(Utilities.get_closest_egg_square(pick_up.global_position))
	await get_tree().create_timer(randf_range(RESPAWN_DELAY.x, RESPAWN_DELAY.y)).timeout
	_respawn_pick_up()


func _respawn_pick_up() -> void:
		var pick_up : Node3D = pick_up_.instantiate()
		var free_square : Node3D = level.get_rand_free_square()
		
		pick_up.effect = level_pick_ups.pick_random()
		add_child(pick_up, true)
		pick_up.global_position = Vector3(free_square.global_position.x, 0, \
													free_square.global_position.z)
		pick_up.despawn.connect(_pick_up_despawned)
