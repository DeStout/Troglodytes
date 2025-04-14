extends Node


enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }


func anims_to_constant(character : CharacterBody3D) -> void:
	var anim_list : Array = character.anim_player.get_animation_list()
	for anim_name in anim_list:
		var anim = character.anim_player.get_animation(anim_name)
		for track in anim.get_track_count():
			anim.track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)


func get_closest_egg_square(pos : Vector3) -> Node3D:
	var egg_squares = get_tree().get_nodes_in_group("EggSquares")
	var min_dist := 9999.9
	var closest : Node3D
	for egg_square in egg_squares:
		var dist = pos.distance_squared_to(egg_square.global_position)
		if dist > min_dist:
			continue
		min_dist = dist
		closest = egg_square
	return closest


func v3_to_v2(pos3 : Vector3) -> Vector2:
	return Vector2(pos3.x, pos3.z)


func get_move_dir_vect(move_dir : DIRECTIONS) -> Vector2:
	var target_dir : Vector2
	match move_dir:
		DIRECTIONS.UP:
			target_dir = Vector2.UP
		DIRECTIONS.DOWN:
			target_dir = Vector2.DOWN
		DIRECTIONS.LEFT:
			target_dir = Vector2.LEFT
		DIRECTIONS.RIGHT:
			target_dir = Vector2.RIGHT
	return target_dir
