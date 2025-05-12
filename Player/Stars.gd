extends MeshInstance3D


const ROT_SPEED := 270

var rot := 0.0


func _process(delta: float) -> void:
	rot += delta * ROT_SPEED
	rotation_degrees.y = snappedf(rot, 40)


func show_stars(is_show : bool) -> void:
	set_process(is_show)
	visible = is_show
