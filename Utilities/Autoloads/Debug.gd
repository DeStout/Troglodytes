extends Node


@export var fps : Label


func _physics_process(delta: float) -> void:
	fps.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))


func network_debug_data(debug_data : Dictionary) -> void:
	print("Network Debug Data: %s" % debug_data)
