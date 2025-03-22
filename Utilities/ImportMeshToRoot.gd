@tool
extends EditorScenePostImport

func _post_import(root : Node):
	return root.get_child(0)
