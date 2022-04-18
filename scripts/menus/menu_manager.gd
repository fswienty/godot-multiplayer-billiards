extends Node

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false

var _err

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu


func _ready():
	_err = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	_err = lobby_menu.connect("game_started", self, "_on_game_started")

	var is_returning: bool = get_tree().get_network_unique_id() != 0

	Globals.DEBUG_MODE = DEBUG_MODE
	Globals.DEBUG_HUD = DEBUG_HUD
	if DEBUG_MODE:
		connect_menu.player_name = "debug_host"
		connect_menu._on_Button_pressed("host")
		Lobby.player_infos = {1: {name = "debug_host", team = 1}}
		connect_menu.hide()
		lobby_menu.show()
		_on_game_started()
	else:
		connect_menu.show()
		lobby_menu.hide()
		if is_returning:
			_on_entered_lobby()


func _on_entered_lobby():
	connect_menu.hide()
	lobby_menu.open()


func _on_game_started():
	get_tree().refuse_new_network_connections = true
	print("game will be started with: ", Lobby.player_infos)

	# load game scene
	_err = get_tree().change_scene("res://scenes/EightBall.tscn")
