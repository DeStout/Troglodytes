extends MultiplayerSpawner


var footprint_ := load("res://Levels/FX/Footprint.tscn")
var fire_ball_ := load("res://Player/FireBall.tscn")

enum FX { FOOTPRINT, FIRE_BALL }


func _ready() -> void:
	spawn_function = _spawn_fire_ball


func spawn_footprint(character : CharacterBody3D, foot_down : bool) -> void:
	var footprint : Decal = footprint_.instantiate()
	var foot_pos : Vector3 = character.right_foot.global_position if foot_down \
											else character.left_foot.global_position
	
	footprint.set_up(character)
	add_child(footprint, true)
	footprint.global_position = foot_pos
	#footprint.set_deferred("global_position", foot_pos)
	footprint.rotation.y = character.basis.get_euler().y
	footprint.scale.x = int(foot_down) * 2 - 1


func spawn_fire_ball(player : Player) -> void:
	spawn_function = _spawn_fire_ball
	spawn({"pos" : player.global_position, "move_dir" : player.move_dir})


func _spawn_fire_ball(player_data : Dictionary) -> Node3D:
	var fire_ball : Node3D = fire_ball_.instantiate()
	fire_ball.position = player_data["pos"]
	fire_ball.move_dir = player_data["move_dir"]
	fire_ball.align_to_dir()
	
	return fire_ball
