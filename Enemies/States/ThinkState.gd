class_name ThinkState extends State

const MOVE_DIST := Vector2i(2, 16)
const SEEK_DIST := 12.0

@export var anim_player : AnimationPlayer
@export var wall_check : RayCast3D

var _next_action := ""


func enter() -> void:
	#print(character.name, ": Enter ThinkState")
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
		
		target = _set_valid_target(target)
		if !target.is_equal_approx(character.position):
			character.move_dir = move_dir
			character.target_square = Utilities.v3_to_v2(target)
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
	dirs.sort_custom(func(dir1 : Vector2, dir2 : Vector2):
		return dir1.length() > dir2.length())
		
	for dir in dirs:
		dir *= snappedi(roundi(player_dist), 2)
		var target := Utilities.v2_to_v3(dir)
		
		target = _set_valid_target(target)
		if !target.is_equal_approx(character.position):
			character.move_dir = Utilities.get_move_dir(dir)
			character.target_square = Utilities.v3_to_v2(target)
			return
	
	_set_random_target()


func _set_valid_target(target : Vector3) -> Vector3:
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


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
