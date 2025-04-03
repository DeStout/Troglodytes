extends Camera3D

@onready var viewport_size := get_viewport().get_visible_rect().size
var w_margins : Vector2
var h_margins : Vector2
@export var margin_perc := Vector2(0.75, 0.65)
@export var player : Player


func _ready() -> void:
	w_margins = Vector2((1.0 - margin_perc.x) * viewport_size.x, margin_perc.x * viewport_size.x)
	h_margins = Vector2((1.0 - margin_perc.y) * viewport_size.y, margin_perc.y * viewport_size.y)


func _process(delta: float) -> void:
	var viewport_pos := unproject_position(player.global_position)
	if w_margins.x > viewport_pos.x or w_margins.y < viewport_pos.x:
		position.x += player.speed * sign(viewport_pos.x - viewport_size.x / 2) * delta
	if h_margins.x > viewport_pos.y or h_margins.y < viewport_pos.y:
		position.z += player.speed * sign(viewport_pos.y - viewport_size.y / 2) * delta
