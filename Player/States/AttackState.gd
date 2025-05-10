class_name AttackState extends State


@export var input_sync : MultiplayerSynchronizer
var player_input : Dictionary[String, Variant] = {"dir_input" : Vector2i.ZERO,
												"attack_input" : false}


func _ready() -> void:
	input_sync.input_update.connect(_update_input)


func enter() -> void:
	#print("Enter AttackState")
	character.anim_player.speed_scale = 1.0
	character.attack()
	character._footstep(true)
	character._footstep(false)


func _update_input(new_input : Dictionary[String, Variant]) -> void:
	if active:
		player_input = new_input
		print("AttackState - Update Input - %s" % player_input)


func _input(event: InputEvent) -> void:
	if !active:
		return
		
	if event is InputEventKey and event.is_action_pressed("Attack"):
		character.attack()
	elif event is InputEventMouseButton and event.is_action_pressed("Attack"):
		character.attack()


func update(delta) -> void:
	pass


func physics_update(delta) -> void:
	pass


func attack_finished() -> void:
	transition.emit(self, character.get_prev_state())


func attacked() -> void:
	if !character.invincible_timer.time_left:
		transition.emit(self, "StunState")


#func exit() -> void: pass
