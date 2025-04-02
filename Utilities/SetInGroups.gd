@tool
extends EditorScript


func _run() -> void:
	for square in get_scene().board.egg_squares.get_children():
		if !square.is_in_group("EggSquares"):
			print(square)
			square.add_to_group("EggSquares", true)
