extends Camera3D

@export var camera_locked := false
@export var camera_x_centered := false
@export var camera_y_centered := false
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
	
	var project_pos : Vector2
	match ENetNetwork.get_player_number():
		0:
			project_pos = Vector2(w_margins.x, h_margins.x)
		1:
			project_pos = Vector2(w_margins.y, h_margins.x)
		2:
			project_pos = Vector2(w_margins.x, h_margins.y)
		3:
			project_pos = Vector2(w_margins.y, h_margins.y)
	var temp_plane = Plane(Vector3.UP)
	var cam_pos = temp_plane.intersects_ray(project_ray_origin(project_pos), 
												project_ray_normal(Vector2.ZERO))
	print("%s\n%s\n%s\n" % ["%s %s" % [w_margins, h_margins], project_pos, cam_pos])
	if !camera_x_centered:
		global_position.x -= cam_pos.x - player.global_position.x
	if !camera_y_centered:
		global_position.z -= cam_pos.z - player.global_position.z
	
	set_process(true)


func _process(delta: float) -> void:
	if !player or !is_inside_tree():
		return
		
	var viewport_pos := unproject_position(player.global_position)
	if !camera_x_centered and (w_margins.x > viewport_pos.x or w_margins.y < viewport_pos.x):
		position.x += player.speed * sign(viewport_pos.x - viewport_size.x / 2) * delta
	if !camera_y_centered and (h_margins.x > viewport_pos.y or h_margins.y < viewport_pos.y):
		position.z += player.speed * sign(viewport_pos.y - viewport_size.y / 2) * delta
