extends Node

var connect_menu_open_anim: AnimationPlayer
var lobby_menu_open_anim: AnimationPlayer

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false
export var DEBUG_CONSOLE: bool = false

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu

var __


func _ready():
	__ = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	__ = lobby_menu.connect("game_started", self, "_on_game_started")
	__ = lobby_menu.connect("went_back", self, "_on_backed_out_of_lobby")

	connect_menu_open_anim = Animations.fade_in_anim(connect_menu, Globals.menu_transition_time)
	lobby_menu_open_anim = Animations.fade_in_anim(lobby_menu, Globals.menu_transition_time)

	GlobalUi.hide_error()
	get_tree().refuse_new_network_connections = false
	var is_returning: bool = get_tree().get_network_unique_id() > 0

	Globals.DEBUG_MODE = DEBUG_MODE
	Globals.DEBUG_HUD = DEBUG_HUD
	GlobalUi.set_console_visible(DEBUG_CONSOLE)
	if DEBUG_MODE:
		connect_menu.player_name_input.text = "debug_host"
		connect_menu._on_HostButton_pressed()
		Lobby.player_infos = {1: {name = "debug_host", team = 1}}
		connect_menu.hide()
		lobby_menu.show()
		_on_game_started()
		return

	if is_returning:
		connect_menu.hide()
		lobby_menu.init()
		lobby_menu.show()
		lobby_menu_open_anim.play("anim")
		return

	connect_menu.show()
	lobby_menu.hide()
	connect_menu_open_anim.play("anim")


func _on_entered_lobby():
	GlobalUi.hide_error()
	connect_menu_open_anim.play_backwards("anim")
	yield(connect_menu_open_anim, "animation_finished")
	connect_menu.hide()
	lobby_menu.init()
	lobby_menu.show()
	lobby_menu_open_anim.play("anim")


func _on_backed_out_of_lobby():
	GlobalUi.hide_error()
	get_tree().refuse_new_network_connections = false
	lobby_menu_open_anim.play_backwards("anim")
	yield(lobby_menu_open_anim, "animation_finished")
	lobby_menu.hide()
	connect_menu.show()
	connect_menu_open_anim.play("anim")


func _on_game_started():
	GlobalUi.hide_error()
	get_tree().refuse_new_network_connections = true
	lobby_menu_open_anim.play_backwards("anim")
	yield(lobby_menu_open_anim, "animation_finished")
	print("game will be started with: ", Lobby.player_infos)
	__ = get_tree().change_scene("res://scenes/EightBall.tscn")
