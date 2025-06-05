extends Decal


const FADE_TIME := 5.0

var player_print := load("res://Levels/FX/Materials/PlayerFootstep.png")
var enemy_print := load("res://Levels/FX/Materials/EnemyFootstep.png")

var fade := 0.0


func _process(delta: float) -> void:
	modulate.a = (FADE_TIME - fade) / FADE_TIME
	fade += delta
	if fade >= FADE_TIME:
		queue_free()


func set_up(character : CharacterBody3D) -> void:
	if character is Player:
		texture_albedo = player_print
	elif character is Enemy:
		texture_albedo = enemy_print
