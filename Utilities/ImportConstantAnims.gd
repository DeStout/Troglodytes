@tool
extends EditorScenePostImport

func _post_import(root : Node):
	var anim_player : AnimationPlayer = root.get_node("AnimationPlayer")
	var anim_list := anim_player.get_animation_list()
	for anim_name in anim_list:
		print(anim_name, ": Set nearest interp.")
		var anim = anim_player.get_animation(anim_name)
		for track in anim.get_track_count():
			anim.track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)
	
	return root
