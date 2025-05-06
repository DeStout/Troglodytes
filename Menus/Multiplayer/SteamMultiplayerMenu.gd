extends CenterContainer


@export var host_join_menu : Control
@export var lobby_list_menu : Control
@export var lobby_menu : Control
@export var lobby_join_button : Button


func host_button() -> void:
	_connect_connection_signals(true, true)
	SteamNetwork.create_lobby()


func join_button() -> void:
	host_join_menu.visible = false
	lobby_list_menu.visible = true
	lobby_list_menu.refresh_lobby_list()


func show_lobby(is_host : bool) -> void:
	_connect_connection_signals(false, false)
	if is_host:
		host_join_menu.visible = false
		lobby_join_button.visible = true
	else:
		if !SteamNetwork.server_disconnected.is_connected(back_button):
			SteamNetwork.server_disconnected.connect(back_button)
		lobby_list_menu.visible = false
		lobby_join_button.visible = false
	lobby_menu.set_up()
	lobby_menu.visible = true


func lobby_selected(lobby_id : int) -> void:
	_connect_connection_signals(true, false)
	if !SteamNetwork.connection_failed.is_connected(connection_failed):
		SteamNetwork.connection_failed.connect(connection_failed)
	SteamNetwork.join_lobby(lobby_id)


func _connect_connection_signals(is_connect : bool, is_host : bool) -> void:
	if is_connect:
		if !SteamNetwork.connection_successful.is_connected(show_lobby):
			SteamNetwork.connection_successful.connect(show_lobby.bind(is_host))
		if !SteamNetwork.connection_failed.is_connected(connection_failed):
			SteamNetwork.connection_failed.connect(connection_failed)
	else:
		if SteamNetwork.connection_successful.is_connected(show_lobby):
			SteamNetwork.connection_successful.disconnect(show_lobby.unbind(1))
		if SteamNetwork.connection_failed.is_connected(connection_failed):
			SteamNetwork.connection_failed.disconnect(connection_failed)


# Signaled from SteamNetwork._connection_failed()
func connection_failed() -> void:
	_connect_connection_signals(false, false)


# Signaled from SteamNetwork.server_disconnected, LobbyListMenu/Back, Lobby/Disconnect
func back_button() -> void:
	if SteamNetwork.server_disconnected.is_connected(back_button):
		SteamNetwork.server_disconnected.disconnect(back_button)
	if SteamNetwork.peer:
		SteamNetwork.reset_peer()
	lobby_menu.reset()
		
	host_join_menu.visible = true
	lobby_list_menu.visible = false
	lobby_menu.visible = false
