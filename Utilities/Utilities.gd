extends Node


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
