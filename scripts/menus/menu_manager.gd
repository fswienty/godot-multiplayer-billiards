extends Node

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu

var __


func _ready():
	__ = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	__ = lobby_menu.connect("game_started", self, "_on_game_started")
	__ = lobby_menu.connect("went_back", self, "_on_backed_out_of_lobby")

	GlobalUi.hide_error()
	get_tree().refuse_new_network_connections = false
	var is_returning: bool = get_tree().get_network_unique_id() > 0

	Globals.DEBUG_MODE = DEBUG_MODE
	Globals.DEBUG_HUD = DEBUG_HUD
	if DEBUG_MODE:
		connect_menu.player_name_input.text = "debug_host"
		connect_menu._on_HostButton_pressed()
		Lobby.player_infos = {1: {name = "debug_host", team = 1}}
		connect_menu.hide()
		lobby_menu.show()
		_on_game_started()
	else:
		connect_menu.open()
		lobby_menu.hide()
		if is_returning:
			_on_entered_lobby()


func _on_entered_lobby():
	connect_menu.hide()
	lobby_menu.open()


func _on_backed_out_of_lobby():
	get_tree().network_peer = null
	lobby_menu.hide()
	connect_menu.open()


func _on_game_started():
	GlobalUi.hide_error()
	get_tree().refuse_new_network_connections = true
	print("game will be started with: ", Lobby.player_infos)
	# load game scene
	__ = get_tree().change_scene("res://scenes/EightBall.tscn")
