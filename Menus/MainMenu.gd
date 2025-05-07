extends Control


@export var game : Node
@export var main_menu : Control
@export var mult_button : Button
@export var mult_menu : Control
@export var options_menu : Control


func _single_player_button() -> void:
	Pause.update()
	game.start_game()


func _mult_button() -> void:
	main_menu.visible = false
	mult_menu.visible = true


func _options_button() -> void:
	main_menu.visible = false
	options_menu.visible = true


func _back_button() -> void:
	main_menu.visible = true
	mult_menu.visible = false
	options_menu.visible = false


func _quit_button() -> void:
	get_tree().quit()
