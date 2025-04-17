extends Node


enum DIRECTIONS { UP, DOWN, LEFT, RIGHT }

var rand_chars := ["G", "H", "I", "J", "K", "L", "M", "N", "P", "Q", \
										"R", "S", "T", "U", "V", "W", "X", "Y", "Z"]


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


func encode_ip(ip : String) -> String:
	if !ip.is_valid_ip_address():
		return "Invalid"
	var ip_split = ip.split(".")
	var encoded := ""
	for i in range(ip_split.size()):
		encoded += "%X" % int(ip_split[i])
		if i >= ip_split.size() - 1:
			break
		encoded += rand_chars.pick_random()
	return encoded


func decode_ip(encoded : String) -> String:
	# Checks normal ip address or code is invalid
	if encoded.is_valid_ip_address():
		return encoded
	if encoded.length() < 7 or encoded.length() > 11:
		return "Invalid"
	
	# Store indices of encoded ip splitters
	encoded = encoded.to_upper()
	var splitters := []
	for char in rand_chars:
		var start := 0
		for i in range(encoded.count(char)):
			var index = encoded.find(char, start)
			start = index + 1
			if index >= 0:
				splitters.append(index)
	splitters.sort()
	
	# Pull substrings using stored indices, convert from hex, recombine into valid ip
	var ip := ""
	var from = 0
	var length = splitters[0]
	for i in range(splitters.size()+1):
		ip += str(encoded.substr(from, length).hex_to_int())
		
		if i == splitters.size():
			break
			
		from = splitters[i]+1
		length = -1
		if i <= splitters.size() - 2:
			length = splitters[i+1] - splitters[i] - 1
		ip += "."
		
	if !ip.is_valid_ip_address():
		return "Invalid"
	return ip
