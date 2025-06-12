extends Node3D


signal collected

const SCORE_VALUE := 250
const ROTATION_SPEED := 60.0
const AMPLITUDE := 0.1

@onready var mesh := $Mesh
@onready var pos_offset : float = mesh.position.y
@onready var time_offset := randf() * TAU
var rot := rad_to_deg(randf() * TAU)
var time := 0.0


@onready var collision := $Area/Collision
@onready var pick_up_sfx := $PickUpSFX


func _ready() -> void:
	collision.disabled = !multiplayer.is_server()


func _process(delta: float) -> void:
	time += delta
	rot = fmod(rot + (ROTATION_SPEED * delta), 360)
	if is_zero_approx(snapped(fmod(time, 0.25), 0.05)):
		rotation_degrees.y = rot
		mesh.position.y = pos_offset + AMPLITUDE * sin(time + time_offset)


func _collected(player : CharacterBody3D) -> void:
	if player is Player and multiplayer.is_server():
		pick_up_sfx.play()
		mesh.visible = false
		collision.call_deferred("set_disabled", true)
		player.give_score(SCORE_VALUE)
		collected.emit(self)
		await pick_up_sfx.finished
		queue_free()
