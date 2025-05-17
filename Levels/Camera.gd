extends Camera3D

@export var camera_locked := false
@onready var viewport_size := get_viewport().get_visible_rect().size
var w_margins : Vector2
var h_margins : Vector2
@export var margin_perc := Vector2(0.75, 0.65)
var player : Player


func _ready() -> void:
	set_process(false)
	w_margins = Vector2((1.0 - margin_perc.x) * viewport_size.x, margin_perc.x * viewport_size.x)
	h_margins = Vector2((1.0 - margin_perc.y) * viewport_size.y, margin_perc.y * viewport_size.y)


func set_player(new_player : CharacterBody3D) -> void:
	if !(new_player is Player) or !new_player.is_multiplayer_authority():
		return
		
	player = new_player
	
	if camera_locked:
		return
	var temp_plane = Plane(Vector3.UP)
	var cam_pos = temp_plane.intersects_ray(global_position, 
										project_ray_normal(Vector2.ZERO))
	global_position -= cam_pos - player.global_position
	set_process(true)


func _process(delta: float) -> void:
	var viewport_pos := unproject_position(player.global_position)
	if w_margins.x > viewport_pos.x or w_margins.y < viewport_pos.x:
		position.x += player.speed * sign(viewport_pos.x - viewport_size.x / 2) * delta
	if h_margins.x > viewport_pos.y or h_margins.y < viewport_pos.y:
		position.z += player.speed * sign(viewport_pos.y - viewport_size.y / 2) * delta
