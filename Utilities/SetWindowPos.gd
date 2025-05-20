# The purpose of this class is to determine how many instances of the game you are running
# and move them accordingly. Up to 4 max. Why? I only have a 1080p monitor.
extends Node


var show_on_main_screen : bool

var main_tl : Vector2 = Vector2(0, 32)
var main_tr : Vector2 = Vector2(960, 32)
var main_bl : Vector2 = Vector2(0, 540+10)
var main_br : Vector2 = Vector2(960, 540+10)

var second_tl : Vector2 = Vector2(1920, 32)
var second_tr : Vector2 = Vector2(2880, 32)
var second_bl : Vector2 = Vector2(1920, 540+10)
var second_br : Vector2 = Vector2(2880, 540+10)


func set_window_positions(set_window_positions : bool, main_screen : bool) -> void:
	show_on_main_screen = main_screen
	
	if !set_window_positions:
		return
	if not OS.has_feature("editor"):
		print("This is exported build, do not run the local testing stuff")
		return

	var launch_args = OS.get_cmdline_args()
	_set_window_pos(launch_args)


func _set_window_pos(launch_arguments: PackedStringArray):
	var screen_size := DisplayServer.screen_get_size()
	var screen_width : float = screen_size.x
	var screen_height : float = screen_size.y - 64 - 40
	var new_window_size := Vector2(screen_width/2.0, screen_height/2.0)

	var window := get_window()
	window.size = new_window_size

	if launch_arguments.has("server"):
		name = "Server"; window.title = "Server"
		if show_on_main_screen:
			window.position = main_tl
		else:
			window.position = second_tl
			
	elif launch_arguments.has("client1"):
		name = "Client1"; window.title = "Client1"
		if show_on_main_screen:
			window.position = main_tr
		else:
			window.position = second_tr
			
	elif launch_arguments.has("client2"):
		name = "Client2"; window.title = "Client2"
		#window.size = Vector2(960, 418)
		if show_on_main_screen:
			window.position = main_bl
		else:
			window.position = second_bl
			
	elif launch_arguments.has("client3"):
		name = "Client3"; window.title = "Client3"
		#window.size = Vector2(960, 418)
		if show_on_main_screen:
			window.position = main_br
		else:
			window.position = second_br
