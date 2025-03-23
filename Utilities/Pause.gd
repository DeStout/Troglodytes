extends Node


@onready var pause := $Pause


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		pause.visible = get_tree().paused
		
