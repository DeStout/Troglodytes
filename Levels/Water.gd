extends Node3D


const Y_AMP := 0.19

@onready var pos_offset := position
@onready var time_offset := fmod(position.z, 0.9)
var time := 0.0


func _process(delta: float) -> void:
	position.x = sin(time + time_offset) + pos_offset.x
	position.y = Y_AMP * sin(time + time_offset) + pos_offset.y
	time += delta
