extends MeshInstance3D


func flash() -> void:
	visible = !visible


func player_entered(player : CharacterBody3D) -> void:
	if player is Player:
		get_tree().call_deferred("reload_current_scene")
