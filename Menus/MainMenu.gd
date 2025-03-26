extends Control


@export var game : Node
@export var main_menu : Control
@export var options_menu : Control


func _play_button() -> void:
	Pause.update()
	game.start_game()


func _options_button() -> void:
	main_menu.visible = false
	options_menu.visible = true


func _options_back_button() -> void:
	main_menu.visible = true
	options_menu.visible = false


func _quit_button() -> void:
	get_tree().quit()
