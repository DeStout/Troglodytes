extends CenterContainer


@export var host_join_menu : Control
@export var lobby_list_menu : Control
@export var lobby_menu : Control
@export var lobby_join_button : Button


func host_button() -> void:
	if !Network.initialize_steam():
		return
	_connect_connection_signals(true, true)
	Network.create_lobby()


func join_button() -> void:
	if !Network.initialize_steam():
		return
	host_join_menu.visible = false
	lobby_list_menu.visible = true
	lobby_list_menu.refresh_lobby_list()


# Signaled from LobbyListMenu._lobby_selected()
func lobby_selected(lobby_id : int) -> void:
	_connect_connection_signals(true, false)
	if !Network.connection_failed.is_connected(connection_failed):
		Network.connection_failed.connect(connection_failed)
	Network.join_lobby(lobby_id)


func _connect_connection_signals(is_connect : bool, is_host : bool) -> void:
	if is_connect:
		if !Network.connection_successful.is_connected(show_lobby):
			Network.connection_successful.connect(show_lobby.bind(is_host))
		if !Network.connection_failed.is_connected(connection_failed):
			Network.connection_failed.connect(connection_failed)
	else:
		if Network.connection_successful.is_connected(show_lobby):
			Network.connection_successful.disconnect(show_lobby.unbind(1))
		if Network.connection_failed.is_connected(connection_failed):
			Network.connection_failed.disconnect(connection_failed)


func connection_failed() -> void:
	_connect_connection_signals(false, false)


func show_lobby(is_host : bool) -> void:
	_connect_connection_signals(false, false)
	if is_host:
		host_join_menu.visible = false
		lobby_join_button.visible = true
	else:
		if !Network.server_disconnected.is_connected(back_button):
			Network.server_disconnected.connect(back_button)
		lobby_list_menu.visible = false
		lobby_join_button.visible = false
	lobby_menu.update()
	lobby_menu.visible = true


# Signaled from Network.server_disconnected, LobbyListMenu/Back, Lobby/Disconnect
func back_button() -> void:
	if Network.server_disconnected.is_connected(back_button):
		Network.server_disconnected.disconnect(back_button)
	if Network.steam_init:
		Network.shutdown_steam()
		
	host_join_menu.visible = true
	lobby_list_menu.visible = false
	lobby_menu.visible = false
