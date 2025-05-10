extends MultiplayerSpawner


@export var game : Game


func _ready() -> void:
	spawn_function = _spawn_new_level


func _spawn_new_level(new_level : int) -> Level:
	var level = load(get_spawnable_scene(new_level)).instantiate()
	game.level = level
	level.game = game
	return level
