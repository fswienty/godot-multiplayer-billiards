extends Node

export var DEBUG_MODE: bool = false

var _err

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu


func _ready():
	_err = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	_err = lobby_menu.connect("game_started", self, "_on_game_started")

	if DEBUG_MODE:
		Globals.DEBUG_MODE = true
		connect_menu.player_name = "debug_host"
		connect_menu._on_HostButton_pressed()
		Lobby.player_infos = {1: {name = "debug_host", team = 1}}
		connect_menu.hide()
		lobby_menu.initialize()
		lobby_menu.show()
		_on_game_started()
	else:
		connect_menu.show()
		lobby_menu.hide()


func _on_entered_lobby():
	connect_menu.hide()
	lobby_menu.initialize()
	lobby_menu.show()


func _on_game_started():
	print("game will be started with: ", Lobby.player_infos)

	# load game scene
	_err = get_tree().change_scene("res://scenes/EightBall.tscn")
