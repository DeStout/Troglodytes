extends MultiplayerSpawner


var footprint_ := load("res://Levels/FX/Footprint.tscn")
var fire_ball_ := load("res://Player/FireBall.tscn")


func spawn_footprint(character : CharacterBody3D, foot_down) -> void:
	var footprint : Decal = footprint_.instantiate()
	var foot_pos : Vector3 = character.right_foot.global_position if foot_down \
											else character.left_foot.global_position
	var char_rot := character.basis.get_euler().y
	
	footprint.set_up(character)
	add_child(footprint, true)
	footprint.global_position = foot_pos
	footprint.rotation.y = char_rot
	footprint.scale.x = int(foot_down) * 2 - 1


func spawn_fire_ball(player : Player) -> void:
	var fire_ball : Node3D = fire_ball_.instantiate()
	fire_ball.emitter = player
	fire_ball.move_dir = player.move_dir
	add_child(fire_ball, true)
	fire_ball.align_to_dir()
	fire_ball.position = player.global_position
