extends MultiplayerSpawner


var spawn_hole_ := load("res://Levels/Props/SpawnHole.tscn")

@export var characters : MultiplayerSpawner
@export var egg_squares : Node3D
@export var home_squares : Node3D
@export var walls : Node3D


func _ready() -> void:
	spawn_function = _add_spawn_hole
	
	if multiplayer.is_server():
		_add_egg_squares()
		_add_home_squares()


func _add_egg_squares() -> void:
	for square in egg_squares.get_children():
		#if !square.is_in_group("PlayerSquares"):
		square.add_to_group("EggSquares", true)


func _add_home_squares() -> void:
	for square in home_squares.get_children():
		square.add_to_group("HomeSquares", true)


func _add_spawn_hole(new_pos : Vector3) -> CSGCylinder3D:
	var spawn_hole : CSGCylinder3D = spawn_hole_.instantiate()
	spawn_hole.position = Vector3(new_pos.x, -0.8, new_pos.z)
	characters.spawn_function = characters._spawn_enemy
	spawn_hole.open_finished.connect(characters.spawn.bind(spawn_hole))
	return spawn_hole


func level_complete_clean_up() -> void:
	for egg_square in get_tree().get_nodes_in_group("EggSquares"):
		egg_square.remove_from_group("EggSquares")
	for home_square in get_tree().get_nodes_in_group("HomeSquares"):
		home_square.remove_from_group("HomeSquares")
