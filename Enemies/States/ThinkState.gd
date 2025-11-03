class_name ThinkState extends State

const MOVE_DIST := Vector2i(2, 16)
const SEEK_DIST := 10

@export var anim_player : AnimationPlayer
@export var wall_check : RayCast3D

var _next_action := ""
var init_think := true


func enter() -> void:
	#print(character.name, ": Enter ThinkState")

	character.characters.take_free_square(Utilities.get_closest_egg_square(\
												character.global_position), true)
	anim_player.animation_finished.connect(_act)
	anim_player.play("Think")
	_next_action = _choose_action()


func _choose_action() -> String:
	var action := randi() % 2
	match action:
		0:
			_set_random_target()
		1:
			_seek_player()
		_:
			_set_random_target()
	return "SearchState"


func _set_random_target() -> void:
	#print("%s: Moving random" % character.name)
	var directions := Utilities.DIRECTIONS.keys()
	directions.shuffle()
	for dir in directions:
		var move_dir = Utilities.DIRECTIONS[dir]
		var move_dist_vect := Utilities.get_move_dir_vect(move_dir)
		move_dist_vect *= snappedi(randi_range(MOVE_DIST.x, MOVE_DIST.y), 2)
		var target := Utilities.v2_to_v3(move_dist_vect)

		target = _check_wall_collisions(target)
		target = _check_target_reachable(target, move_dist_vect.normalized())
		if !target.is_equal_approx(character.position):
			character.move_dir = move_dir
			character.target_square = Utilities.v3_to_v2(target)
			character.debug_target.global_position = target
			break


func _seek_player() -> void:
	#print("%s: Seeking player" % character.name)
	if !character.characters.players.size():
		_set_random_target()
		return

	var seek_player : Player = character.characters \
									.get_closest_player(character.global_position)
	var player_pos := seek_player.global_position
	var player_dist := character.global_position.distance_to(player_pos)
	if player_dist > SEEK_DIST:
		_set_random_target()
		return

	var dir_to := Utilities.v3_to_v2(\
							character.global_position.direction_to(player_pos))
	var dirs = [Vector2(dir_to.x, 0), Vector2(0, dir_to.y)]
	dirs.sort_custom(func(dir1 : Vector2, dir2 : Vector2) -> bool:
		return dir1.length() > dir2.length())

	for dir in dirs:
		dir *= snappedi(roundi(player_dist), 2)
		var target := Utilities.v2_to_v3(dir)

		target = _check_wall_collisions(target)
		target = _check_target_reachable(target, dir.normalized())
		if !target.is_equal_approx(character.position):
			character.move_dir = Utilities.get_move_dir(dir)
			character.target_square = Utilities.v3_to_v2(target)
			character.debug_target.global_position = target
			return

	_set_random_target()


func _check_wall_collisions(target : Vector3) -> Vector3:
	var ray_target : Vector3 = target + wall_check.global_position
	ray_target = wall_check.to_local(ray_target)
	wall_check.target_position = ray_target
	wall_check.force_raycast_update()
	wall_check.target_position = Vector3.FORWARD
	if wall_check.is_colliding():
		var collision = wall_check.get_collision_point()
		return Utilities.get_closest_egg_square(collision).global_position
	target += character.position
	return Utilities.get_closest_egg_square(target).global_position


func _check_target_reachable(target3 : Vector3, dir_vect : Vector2) -> Vector3:
	var char_pos2 := Utilities.v3_to_v2(character.position)
	var target2 := Utilities.v3_to_v2(target3)
	var egg_squares := get_tree().get_nodes_in_group("EggSquares")\
			# Filter squares if they are along the Enemies chosen row/column
			.filter(func(square3 : Node3D) -> bool:
				var square2 := Utilities.v3_to_v2(square3.position)
				if !is_equal_approx(char_pos2.direction_to(square2)\
															.dot(dir_vect), 1.0):
					return false
				return true)
	if !egg_squares.size():
		return character.position

	# Return a closer position if square position continuity is broken
	# Return initial target otherwise
	for i in range(egg_squares.size()):
		var test_pos := char_pos2 + (2 * (i+1) * dir_vect)
		if !egg_squares.any(func(square3 : Node3D) -> bool:
				if test_pos == Utilities.v3_to_v2(square3.position):
					return true
				return false):
			return Utilities.v2_to_v3(char_pos2 + (2 * i * dir_vect))
	return target3


func _act(_anim_finished : String) -> void:
	anim_player.animation_finished.disconnect(_act)
	transition.emit(self, _next_action)


func attack() -> void:
	anim_player.pause()
	anim_player.animation_finished.disconnect(_act)
	transition.emit(self, "BashState")


func attacked() -> void:
	anim_player.pause()
	anim_player.animation_finished.disconnect(_act)
	transition.emit(self, "HitStunState")


func freeze() -> void:
	anim_player.pause()
	anim_player.animation_finished.disconnect(_act)
	transition.emit(self, "FreezeState")


func burn() -> void:
	anim_player.stop()
	anim_player.animation_finished.disconnect(_act)
	transition.emit(self, "BurnState")


func exit() -> void:
	if init_think:
		init_think = false
		character.characters.take_free_square(Utilities.get_closest_egg_square(\
													character.global_position), false)


#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
