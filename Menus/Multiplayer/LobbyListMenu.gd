extends MarginContainer


@export var lobby_list : VBoxContainer
@export var refresh_button : Button


func refresh_lobby_list() -> void:
	for child in lobby_list.get_children():
		child.queue_free()
	Steam.addRequestLobbyListStringFilter("Game", "Troglodytes", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	Steam.lobby_match_list.connect(_update_lobby_list)


func _update_lobby_list(new_lobbies : Array) -> void:
	Steam.lobby_match_list.disconnect(_update_lobby_list)
	for lobby in new_lobbies:
		var lobby_name := Steam.getLobbyData(lobby, "Name")
		print(lobby_name)
		lobby_list.add_child(_create_lobby_button(lobby_name))


func _create_lobby_button(lobby_name : String) -> Button:
	var button = Button.new()
	button.text = lobby_name
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.theme = load("res://Utilities/MainTheme.tres")
	return button
