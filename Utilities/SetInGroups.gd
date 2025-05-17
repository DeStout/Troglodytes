@tool
extends EditorScript


func _run() -> void:
	for square in get_scene().board.egg_squares.get_children():
		if square.is_in_group("EggSquares"):
			print(square)
			square.remove_from_group("EggSquares")
