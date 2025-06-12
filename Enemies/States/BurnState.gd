class_name BurnState extends State


@export var anim_player : AnimationPlayer
@export var burn_sfx : Array[AudioStreamPlayer]
@export var flame : Sprite3D

var burn_tex := load("res://Enemies/Enemy1Burn_A.png")


func enter() -> void:
	character.rotation.y = PI
	character.disable_collision()
	flame.visible = true
	if character.spawn_hole:
		character.spawn_hole.close()
	character.last_attacker.give_score(character.SCORE_VALUE)
	
	_set_burn_texture.rpc()
	
	for sfx in burn_sfx:
		sfx.play()
	anim_player.play("Burn")
	await burn_sfx[1].finished
	character.die()


@rpc("authority", "call_local")
func _set_burn_texture() -> void:
	var burn_mat = StandardMaterial3D.new()
	burn_mat.albedo_texture = burn_tex
	character.body.set_surface_override_material(0, burn_mat)


#func exit() -> void: pass
#func update(delta) -> void: pass
#func physics_update(delta) -> void: pass
