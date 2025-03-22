extends Node3D


signal collected

const VALUE := 50

@onready var mesh := $Mesh
@onready var collision := $Area/Collision
@onready var pick_up_sfx := $PickUpSFX


func _collected(body : CharacterBody3D) -> void:
	if body is Player:
		pick_up_sfx.play()
		mesh.visible = false
		collision.call_deferred("set_disabled", true)
		Globals.add_to_score(VALUE)
		await pick_up_sfx.finished
		collected.emit(self)
		queue_free()
