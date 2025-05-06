extends CenterContainer


@export var host_join_menu : Control
@export var join_address : TextEdit
@export var lobby_menu : Control
@export var lobby_start_button : Button
@export var lobby_ready_button : Button


func _ready() -> void:
	ENetNetwork.server_joined.connect(show_lobby)
	ENetNetwork.server_disconnected.connect(back_button)


func host_button() -> void:
	ENetNetwork.create_server()


func join_button() -> void:
	ENetNetwork.join_server(join_address.text)


func show_lobby(success : bool, is_host : bool) -> void:
	if success:
		host_join_menu.visible = false
		lobby_menu.update_peers()
		lobby_menu.visible = true
		lobby_start_button.visible = is_host
		lobby_ready_button.visible = !is_host


## Signaled from ENetNetwork._connection_failed()
#func connection_failed() -> void:
	#_connect_connection_signals(false, false)


# Signaled from ENetNetwork.server_disconnected, Lobby/Disconnect
func back_button() -> void:
	if ENetNetwork.peer:
		ENetNetwork.reset_peer()
	lobby_menu.reset()
	
	host_join_menu.visible = true
	lobby_menu.visible = false
