extends CSGCylinder3D


signal open_finished

var tween : Tween


func _ready() -> void:
	if multiplayer.is_server():
		tween = create_tween()
		tween.tween_interval(randf_range(0.0, 1.0))
		tween.tween_method(func(new_radius : float):
			radius = snapped(new_radius, 0.3), 0.0, 0.6, 0.65)
		await tween.finished
		open_finished.emit()


func close() -> void:
	if multiplayer.is_server():
		tween = create_tween()
		tween.tween_method(func(new_radius : float):
			radius = snapped(new_radius, 0.3), 0.6, 0.0, 0.25)
		await tween.finished
		queue_free()
