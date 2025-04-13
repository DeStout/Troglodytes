extends Node3D


const Y_AMP := 0.19

@onready var pos_offset := position
@onready var time_offset := fmod(position.z, 0.9)
var time := 0.0


func _process(delta: float) -> void:
	position.x = snappedf(sin(time + time_offset) + pos_offset.x, 0.15)
	position.y = snappedf(Y_AMP * sin(PI/2 * time + time_offset) + pos_offset.y, 0.1)
	time += delta
