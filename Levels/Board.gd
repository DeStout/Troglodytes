extends MultiplayerSpawner


var spawn_hole_ := load("res://Levels/FX/SpawnHole.tscn")

@export var characters : MultiplayerSpawner
@export var egg_squares : Node3D
@export var home_squares : MultiplayerSpawner
@export var walls : Node3D


func _ready() -> void:
	spawn_function = _add_spawn_hole
	
	_add_egg_squares()
	_add_home_squares()


func _add_egg_squares() -> void:
	for square in egg_squares.get_children():
		square.add_to_group("EggSquares", true)


func _add_home_squares() -> void:
	for square in home_squares.get_children():
		square.add_to_group("HomeSquares", true)


func _add_spawn_hole(new_pos : Vector3) -> SpawnHole:
	var spawn_hole : SpawnHole = spawn_hole_.instantiate()
	characters.spawn_function = characters._spawn_enemy
	spawn_hole.open_finished.connect(characters.spawn.bind(spawn_hole))
	spawn_hole.position = new_pos
	spawn_hole.rotation.y = randf_range(0, TAU)
	return spawn_hole


func freeze_spawn_holes() -> void:
	for spawn_hole in get_node(spawn_path).get_children():
		if spawn_hole is SpawnHole:
			spawn_hole.freeze()


func unfreeze_spawn_holes() -> void:
	for spawn_hole in get_node(spawn_path).get_children():
		if spawn_hole is SpawnHole:
			spawn_hole.unfreeze()


func level_complete_clean_up() -> void:
	for egg_square in get_tree().get_nodes_in_group("EggSquares"):
		egg_square.remove_from_group("EggSquares")
	for home_square in get_tree().get_nodes_in_group("HomeSquares"):
		home_square.remove_from_group("HomeSquares")
