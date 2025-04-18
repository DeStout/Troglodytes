extends MarginContainer


@export var lobby_name : Label
@export var players : Array[Label]


func update() -> void:
	print("Name: %s" % Network.lobby_name)
	lobby_name.text = Network.lobby_name
	for player_label in players:
		player_label.text = "Player%s: " % (players.find(player_label) + 1)
		if players.find(player_label) == 0:
			player_label.text += Network.steam_username
