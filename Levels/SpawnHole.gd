extends CSGCylinder3D


var tween : Tween


func _ready() -> void:
	tween = create_tween()
	tween.tween_method(func(new_radius : float):
		radius = snapped(new_radius, 0.125), 0.0, 0.6, 0.5)
	tween.tween_interval(0.65)
	tween.tween_method(func(new_radius : float):
		radius = snapped(new_radius, 0.125), 0.6, 0.0, 0.25)
	await tween.finished
	queue_free()
