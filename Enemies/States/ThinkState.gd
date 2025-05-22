class_name ThinkState extends State


@export var anim_player : AnimationPlayer
@export var wall_check : RayCast3D

var _next_action := ""


func enter() -> void:
	#print(character.name, ": Enter ThinkState")
	anim_player.animation_finished.connect(_act)
	anim_player.play("Think")
	_next_action = _choose_action()


func _choose_action() -> String:
	_set_search_target()
	return "SearchState"


func _set_search_target() -> void:
	character.move_dir = randi() % Utilities.DIRECTIONS.size()
	var move_dist_vect : Vector2 = Utilities.get_move_dir_vect(character.move_dir)
	move_dist_vect *= randi_range(1, 6) * 2
	var v3_square := Vector3(move_dist_vect.x, 0, move_dist_vect.y)
	
	var ray_target : Vector3 = v3_square + wall_check.global_position
	ray_target = wall_check.to_local(ray_target)
	wall_check.target_position = ray_target
	wall_check.force_raycast_update()
	if wall_check.is_colliding():
		v3_square = Utilities.get_closest_egg_square( \
									wall_check.get_collision_point()).global_position
		character.target_square = Utilities.v3_to_v2(v3_square)
		wall_check.target_position = Vector3.FORWARD
		return
	
	v3_square += character.position
	v3_square = Utilities.get_closest_egg_square(v3_square).global_position
	character.target_square = Utilities.v3_to_v2(v3_square)
	wall_check.target_position = Vector3.FORWARD


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


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
