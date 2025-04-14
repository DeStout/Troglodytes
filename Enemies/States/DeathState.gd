class_name DeathState extends State


const DEATH_SPEED := 25

@onready var death_sfx := $DeathSFX
@onready var wilheim := $Wilheim

var death_dir : Vector2
var velocity : Vector3


func enter() -> void:
	#print(character.name, ": Enter DeathState")
	Globals.add_and_set_score(character.SCORE_VALUE)
	character.disable_collision()
	death_dir = character.get_move_dir_vect(character.death_dir)
	velocity = Vector3(death_dir.x, 0, death_dir.y) * DEATH_SPEED
	if character.spawn_hole:
		character.spawn_hole.close()
	
	if randi_range(0, 25) == 0:
		wilheim.play()
		await wilheim.finished
	else:
		death_sfx.play()
		await death_sfx.finished
	character.die()


func physics_update(delta) -> void:
	if death_sfx.playing:
		death_sfx.volume_db -= delta*65
		#death_sfx.pitch_scale -= delta*0.05
	elif wilheim.playing:
		wilheim.volume_db -= delta*50
	
	character.velocity = velocity
	character.move_and_slide()


#func exit() -> void: pass
#func update(delta) -> void: pass
