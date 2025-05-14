class_name IdleState extends State


@export var input_sync : Node


func _ready() -> void:
	input_sync.input_update.connect(_update_input)


func enter() -> void:
	#print("Enter IdleState")
	character.anim_player.speed_scale = 1.0
	character.anim_player.play("Idle")
	character._footstep(true)
	character._footstep(false)


func _update_input(new_input : Dictionary[String, Variant]) -> void:
	if !active:
		return
	
	if new_input["attack_input"]:
		transition.emit(self, "AttackState")
		
	var dir_input : Vector2 = new_input["dir_input"]
	dir_input = _clear_same_dir_input(dir_input)
	var move_dir := Utilities.get_move_dir(dir_input)
	if move_dir == -1 or character.ray_check(move_dir):
		return
	character.move_dir = move_dir
	transition.emit(self, "MoveState")


func _clear_same_dir_input(dir_input : Vector2) -> Vector2:
	var move_dir := Utilities.get_move_dir_vect(character.move_dir)
	if is_equal_approx(move_dir.x, dir_input.x):
		dir_input.x = 0
	if is_equal_approx(move_dir.y, dir_input.y):
		dir_input.y = 0
	return dir_input


func attacked() -> void:
	if !character.invincible_timer.time_left:
		transition.emit(self, "StunState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
