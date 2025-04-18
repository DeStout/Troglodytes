extends CenterContainer


@export var host_join_menu : Control
@export var lobby_list_menu : Control
@export var lobby_menu : Control
@export var lobby_join_button : Button


func host_button() -> void:
	if !Network.initialize_steam():
		return
	Network.connection_successful.connect(show_lobby.bind(true))
	Network.connection_failed.connect(connection_failed)
	Network.create_lobby()


func join_button() -> void:
	if !Network.initialize_steam():
		return
	host_join_menu.visible = false
	lobby_list_menu.visible = true
	lobby_list_menu.refresh_lobby_list()


func connection_failed() -> void:
	Network.connection_successful.disconnect(show_lobby.unbind(1))
	Network.connection_failed.disconnect(connection_failed)


func show_lobby(is_host : bool) -> void:
	Network.connection_successful.disconnect(show_lobby.unbind(1))
	Network.connection_failed.disconnect(connection_failed)
	if is_host:
		host_join_menu.visible = false
		lobby_join_button.visible = true
	else:
		lobby_list_menu.visible = false
		lobby_join_button.visible = false
	lobby_menu.update()
	lobby_menu.visible = true


func back_button() -> void:
	host_join_menu.visible = true
	lobby_list_menu.visible = false
	lobby_menu.visible = false
