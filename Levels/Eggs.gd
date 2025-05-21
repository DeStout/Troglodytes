extends MultiplayerSpawner


var egg_ := load("res://PickUps/Egg.tscn")


func _ready() -> void:
	spawn_function = _spawn_egg


func _spawn_egg(new_pos : Vector3) -> Node3D:
	var egg = egg_.instantiate()
	egg.position = new_pos
	return egg
