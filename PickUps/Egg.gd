extends Node3D


signal collected

const SCORE_VALUE := 250
const ROTATION_SPEED := 1.0
const AMPLITUDE := 0.1

@onready var mesh := $Mesh
@onready var pos_offset : float = mesh.position.y
@onready var time_offset := randf() * TAU
var time := 0.0


@onready var collision := $Area/Collision
@onready var pick_up_sfx := $PickUpSFX


func _ready() -> void:
	rotation.y = randf() * TAU


func _process(delta: float) -> void:
	rotation.y += ROTATION_SPEED * delta
	mesh.position.y = pos_offset + AMPLITUDE * sin(time + time_offset)
	time += delta


func _collected(body : CharacterBody3D) -> void:
	if body is Player:
		pick_up_sfx.play()
		mesh.visible = false
		collision.call_deferred("set_disabled", true)
		Globals.add_to_score(SCORE_VALUE)
		await pick_up_sfx.finished
		collected.emit(self)
		queue_free()
