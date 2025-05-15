extends Node


@export var fps_label : Label
@export var ping_label : Label


func _physics_process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	if ping_label.visible:
		ping_label.text = "Ping: %s" % str(ENetNetwork.get_ping())


func network_debug_data(debug_data : Dictionary) -> void:
	print("Network Debug Data: %s" % debug_data)
