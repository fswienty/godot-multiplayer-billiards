extends Control

var player_name: String

signal entered_lobby


func _ready():
	pass


func _on_PlayerName_text_changed(name: String):
	player_name = name


func _on_HostButton_pressed():
	if player_name == "":
		print("please enter a name")
		return
	Lobby.host(player_name)
	emit_signal("entered_lobby")


func _on_JoinButton_pressed():
	if player_name == "":
		print("please enter a name")
		return
	Lobby.join(player_name)
	emit_signal("entered_lobby")
