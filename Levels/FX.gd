extends Node3D


enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }

var fire_ball_ := load("res://Player/FireBall.tscn")


func spawn_fire_ball(player : Player) -> void:
	var fire_ball = fire_ball_.instantiate()
	fire_ball.emitter = player
	fire_ball.move_dir = player.move_dir
	add_child(fire_ball)
	fire_ball.align_to_dir()
	fire_ball.position = player.global_position
