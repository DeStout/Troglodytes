extends Control


@export var options : Control


func _input(event: InputEvent) -> void:
	if !Globals.game.level:
		return
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused


func update() -> void:
	options.update()
