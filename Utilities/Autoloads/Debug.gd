extends Node


@export var fps : Label


func _physics_process(delta: float) -> void:
	fps.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
