extends MarginContainer


signal lobby_selected

@export var lobby_list : VBoxContainer
@export var refresh_button : Button


func refresh_lobby_list() -> void:
	for child in lobby_list.get_children():
		child.queue_free()
	Steam.addRequestLobbyListStringFilter("Game", "Troglodytes", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	if !Steam.lobby_match_list.is_connected(_update_lobby_list):
		Steam.lobby_match_list.connect(_update_lobby_list)


func _update_lobby_list(new_lobbies : Array) -> void:
	print(new_lobbies)
	if Steam.lobby_match_list.is_connected(_update_lobby_list):
		Steam.lobby_match_list.disconnect(_update_lobby_list)
	for lobby in new_lobbies:
		var lobby_name := Steam.getLobbyData(lobby, "Name")
		lobby_list.add_child(_create_lobby_button(lobby, lobby_name))


func _create_lobby_button(lobby_id : int, lobby_name : String) -> Button:
	var button = Button.new()
	button.text = lobby_name
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.theme = load("res://Utilities/MainTheme.tres")
	button.pressed.connect(_lobby_selected.bind(lobby_id))
	return button


func _lobby_selected(lobby_id : int) -> void:
	lobby_selected.emit(lobby_id)
