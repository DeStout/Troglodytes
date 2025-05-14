class_name StartState extends State


const START_TIME := 1.0
@onready var start_timer := $StartTimer

@export var input_sync : Node


func _ready() -> void:
	input_sync.input_update.connect(_update_input)


func enter() -> void:
	#print("Enter StartState")
	
	character.anim_player.speed_scale = 1.0
	character.anim_player.play("Idle")
	character._footstep(true)
	character._footstep(false)
	
	character.set_invincible(character.START_INV_TIME)
	if start_timer.time_left:
		start_timer.paused = false
		return
	start_timer.start(START_TIME)


# called from start_timer.timeout
func _start_finished() -> void:
	transition.emit(self, "MoveState")


func _update_input(new_input : Dictionary[String, Variant]) -> void:
	if !active:
		return
	
	var dir_input : Vector2 = new_input["dir_input"]
	var move_dir := Utilities.get_move_dir(dir_input)
	if move_dir == -1 or character.ray_check(move_dir):
		return
	character.move_dir = move_dir
	
	if new_input["attack_input"]:
		start_timer.paused = true
		transition.emit(self, "AttackState")


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
