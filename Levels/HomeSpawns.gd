extends MultiplayerSpawner


var home_ := load(get_spawnable_scene(0))

@export var level : Level
@export var board : MultiplayerSpawner


func _ready() -> void:
	spawn_function = _spawn_home


# home_num chosen in Level for multiplayer synchronization
func _spawn_home(home_num : int) -> MeshInstance3D:
	var home : Node3D = home_.instantiate()
	var home_square : Node3D = get_tree().get_nodes_in_group("HomeSquares")[home_num]
	var home_pos := home_square.global_position
	
	for wall in board.walls.get_children():
		if Utilities.v3_to_v2(wall.global_position) == Utilities.v3_to_v2(home_pos):
			wall.queue_free()
			break
	
	home.level = level
	home.position = home_pos
	home.rotation = home_square.rotation
	
	return home
