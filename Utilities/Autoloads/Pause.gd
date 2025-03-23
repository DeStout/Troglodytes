extends Node


@onready var pause := $BG


func _input(event: InputEvent) -> void:
	if !Globals.game.level:
		return
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		pause.visible = get_tree().paused
		
