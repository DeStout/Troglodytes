class_name BurnState extends State


@export var anim_player : AnimationPlayer
@export var flame : Sprite3D

var burn_tex := load("res://Enemies/Enemy1Burn_A.png")


func enter() -> void:
	character.rotation.y = PI
	character.disable_collision()
	flame.visible = true
	
	var burn_mat = StandardMaterial3D.new()
	burn_mat.albedo_texture = burn_tex
	character.body.set_surface_override_material(0, burn_mat)
	
	anim_player.play("Burn")
	await anim_player.animation_finished
	character.die()


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
