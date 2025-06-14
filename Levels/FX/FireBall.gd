extends Node3D


const SPEED := 16.0

var emitter_id : int
var move_dir : Utilities.DIRECTIONS

@export var collision : CollisionShape3D


func _ready() -> void:
	collision.disabled = !multiplayer.is_server()


func align_to_dir() -> void:
	var target_dir := Utilities.get_move_dir_vect(move_dir)
	basis = Basis.looking_at(Utilities.v2_to_v3(target_dir))


func _physics_process(delta: float) -> void:
	var move_dir3 := Utilities.v2_to_v3(Utilities.get_move_dir_vect(move_dir))
	position += move_dir3 * SPEED * delta


func _body_collided(body : Node3D) -> void:
	if !multiplayer.is_server():
		return
		
	if !body is CharacterBody3D:
		queue_free()
		return
	if body.has_method("burn"):
		body.burn(emitter_id)
		queue_free()


func _despawn() -> void:
	queue_free()
