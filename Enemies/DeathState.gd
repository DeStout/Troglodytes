class_name DeathState extends State


const DEATH_SPEED := 25

@onready var death_sfx := $DeathSFX
@onready var wilheim := $Wilheim

var death_dir : Vector2


func enter() -> void:
	#print(character.name, ": Enter DeathState")
	death_dir = character.get_move_dir_vect(character.death_dir)
	character.velocity = Vector3(death_dir.x, 0, death_dir.y) * DEATH_SPEED
	
	if randi_range(0, 50) == 0:
		wilheim.play()
	else:
		death_sfx.play()


func physics_update(delta) -> void:
	if death_sfx.playing:
		death_sfx.volume_db -= delta*65
		death_sfx.pitch_scale -= delta*0.05
	elif wilheim.playing:
		wilheim.volume_db -= delta*50
	
	character.move_and_slide()


func die() -> void:
	if death_sfx.playing:
		await death_sfx.finished
	elif wilheim.playing:
		await wilheim.finished
	character.die()


#func exit() -> void: pass
#func update(delta) -> void: pass
