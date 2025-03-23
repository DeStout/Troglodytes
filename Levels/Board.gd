@tool
extends Node3D


#region Board Creation
@export_group("BoardCreation")
const PLAYER_SQUARE := "Row2/Square4"
var _walk_mat := load("res://WalkSquare.tres")
var _stone_mat := load("res://StoneSquare.tres")
var _water_mat := load("res://PlayerMat.tres")

const WATER_BUFFER := 4
@export var play_area : CollisionShape3D
@export var board_size := Vector2i(7, 5)
@export_tool_button("Clear Board") var clear_button = _clear_board
@export_tool_button("Create Board") var create_button = _create_board

var _square := MeshInstance3D.new()
var _stone := MeshInstance3D.new()
#endregion

#region Game
@export_group("Game")
@export var level : Node3D
#endregion


func _ready() -> void:
	_square.mesh = BoxMesh.new()
	_stone.mesh = SphereMesh.new()
	_stone.mesh.radius = 0.35
	_stone.mesh.height = 0.7
	_stone.mesh.radial_segments = 12
	_stone.mesh.rings = 12


func _clear_board() -> void:
	var all_characters = level.characters.clear_board()
	for child in get_children():
		child.free()
	play_area.shape.size = Vector3.ONE


func _create_board() -> void:
	_clear_board()
	
	var total_rows := board_size.y * 2 + 1
	for row_num in range(total_rows):
		var new_row = Node3D.new()
		add_child(new_row)
		new_row.name = "Row" + str(row_num + 1)
		new_row.owner = level
		new_row.position.z = -board_size.y + row_num
		
		if row_num % 2 == 1:
			_add_walk_row(new_row)
		else:
			if row_num == 0 or row_num == total_rows - 1:
				_add_stone_row(new_row, true)
			else:
				_add_stone_row(new_row)
	_add_water()
	level.characters.spawn_player(get_node(PLAYER_SQUARE))
	_set_play_area()


func _add_stone_row(row : Node3D, home_row : = false) -> void:
	var total_squares := board_size.x * 2 + 1
	for square_num in range(total_squares):
		var new_square := _square.duplicate()
		row.add_child(new_square)
		new_square.name = "Square" + str(square_num + 1)
		new_square.owner = level
		new_square.position.x = -board_size.x + square_num
		
		if square_num % 2 == 1:
			new_square.set_surface_override_material(0, _walk_mat)
			if home_row:
				new_square.add_to_group("HomeSquares", true)
		else:
			new_square.position.y = 0.1
			new_square.set_surface_override_material(0, _stone_mat)
			
			var new_stone := _stone.duplicate()
			new_square.add_child(new_stone)
			new_stone.name = "Stone"
			new_stone.owner = level
			new_stone.position.y = 1
			new_stone.set_surface_override_material(0, _stone_mat)


func _add_walk_row(row : Node3D) -> void:
	var total_squares := board_size.x * 2 + 1
	for square_num in range(total_squares):
		var new_square := _square.duplicate()
		row.add_child(new_square)
		new_square.name = "Square" + str(square_num + 1)
		new_square.owner = level
		new_square.position.x = -board_size.x + square_num
		new_square.set_surface_override_material(0, _walk_mat)
		
		if square_num == 0 or square_num == total_squares - 1:
			new_square.add_to_group("HomeSquares", true)
		if square_num % 2 == 1:
			new_square.add_to_group("EggSquares", true)


func _add_water() -> void:
	var width := board_size.x * 2 + 1 + WATER_BUFFER * 2
	var height := board_size.y * 2 + 1
	var pos := 1
	for i in range(4):
		var water := _square.duplicate()
		add_child(water)
		water.mesh = water.mesh.duplicate()
		water.name = "Water" + str(i + 1)
		water.owner = level
		water.set_surface_override_material(0, _water_mat)
		if i % 2 == 0:
			water.mesh.size = Vector3(width, 1, WATER_BUFFER)
			water.position.z = pos * (board_size.y + WATER_BUFFER - 1.5)
			water.position.y = -0.1
			print(water.position.z)
		else:
			water.mesh.size = Vector3(WATER_BUFFER, 1, height)
			water.position.x = pos * (board_size.x + WATER_BUFFER - 1.5)
			water.position.y = -0.1
			print(water.position.x)
			pos *= -1

func _set_play_area() -> void:
	play_area.shape.size = Vector3(board_size.x * 2, 1, board_size.y * 2)


func level_complete_clean_up() -> void:
	if !Engine.is_editor_hint():
		for egg_square in get_tree().get_nodes_in_group("EggSquares"):
			egg_square.remove_from_group("EggSquares")
		for home_square in get_tree().get_nodes_in_group("HomeSquares"):
			home_square.remove_from_group("HomeSquares")
