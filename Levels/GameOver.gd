extends Control


const LONG_BLINK := 1.5
const SHORT_BLINK := 0.25

var game : Game

@export var text : MeshInstance3D
@export var camera : Camera3D
@export var continue_text : Label
@export var blink_timer : Timer

var time := 0.0
var cam_start_pos : Vector3


func _ready() -> void:
	set_process_input(false)
	cam_start_pos = camera.global_position
	
	var tween := create_tween()
	#tween.set_parallel(false)
	modulate.a = 0
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.5)
	await tween.finished
	
	if multiplayer.is_server():
		set_process_input(true)
		continue_text.visible = true
		blink_timer.start(LONG_BLINK)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause") or get_tree().paused:
		return
	if event.is_released():
		return
	
	if event is InputEventMouseButton or event is InputEventKey:
		if multiplayer.is_server():
			ENetNetwork.quit_game.rpc()
			return
		game.quit_to_main()


func _process(delta: float) -> void:
	text.rotation_degrees.y = 2 * sin(time)
	camera.position = cam_start_pos + Vector3(0.025 * cos(0.5 * time), 0.025 * sin(0.5 * time), 0)
	
	time += delta


func _blink_continue() -> void:
	continue_text.visible = !continue_text.visible
	blink_timer.start(LONG_BLINK if continue_text.visible else SHORT_BLINK)
