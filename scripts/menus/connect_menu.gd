extends Control

var player_name: String

signal entered_lobby

onready var player_input = $VBoxContainer/PlayerName
onready var host_button = $VBoxContainer/HostButton
onready var join_button = $VBoxContainer/JoinButton


func _ready():
	player_input.connect("text_changed", self, "_on_PlayerName_text_changed")
	host_button.connect("pressed", self, "_on_HostButton_pressed")
	join_button.connect("pressed", self, "_on_JoinButton_pressed")


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
