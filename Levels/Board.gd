extends Node3D


@export var egg_squares : Node3D
@export var home_squares : Node3D
@export var walls : Node3D


func _ready() -> void:
	_add_egg_squares()
	_add_home_squares()


func _add_egg_squares() -> void:
	for square in egg_squares.get_children():
		square.add_to_group("EggSquares", true)


func _add_home_squares() -> void:
	for square in home_squares.get_children():
		square.add_to_group("HomeSquares", true)


func level_complete_clean_up() -> void:
	for egg_square in get_tree().get_nodes_in_group("EggSquares"):
		egg_square.remove_from_group("EggSquares")
	for home_square in get_tree().get_nodes_in_group("HomeSquares"):
		home_square.remove_from_group("HomeSquares")
