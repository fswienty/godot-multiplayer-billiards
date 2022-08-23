extends Node

var show_error_anim: AnimationPlayer

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu
onready var error_label: Label = $ErrorLabel
onready var error_label_timer: Timer = error_label.get_node("Timer")

var __


func _ready():
	__ = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	__ = connect_menu.connect("error_occurred", self, "_on_error_occurred")
	__ = lobby_menu.connect("game_started", self, "_on_game_started")
	__ = lobby_menu.connect("went_back", self, "_on_backed_out_of_lobby")
	__ = lobby_menu.connect("error_occurred", self, "_on_error_occurred")
	__ = error_label_timer.connect("timeout", self, "_slide_out_error_label")
	__ = Lobby.connect("host_left", self, "_on_host_left")
	__ = Lobby.connect("client_left", self, "_on_client_left")

	show_error_anim = Animations.slide_in_anim(error_label, "y", 100, Globals.menu_transition_time)
	error_label.rect_position = Vector2(0, -1000)

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
	error_label.rect_position = Vector2(0, -1000)
	error_label_timer.stop()
	connect_menu.hide()
	lobby_menu.open()


func _on_backed_out_of_lobby():
	if get_tree().get_network_unique_id() == 1:
		rpc("_remove_all_from_lobby")
	get_tree().network_peer = null
	lobby_menu.hide()
	connect_menu.open()


func _on_host_left(_player_name: String):
	# var error_text = "The host has disconnected"
	# rpc("_show_error_to_others", error_text)
	pass


func _on_client_left(player_name: String):
	print("AAAAAAAAAAHH1" + player_name)
	var error_text = player_name + " has left the game"
	rpc("_show_error_to_others", error_text)


func _on_game_started():
	get_tree().refuse_new_network_connections = true
	print("game will be started with: ", Lobby.player_infos)
	# load game scene
	__ = get_tree().change_scene("res://scenes/EightBall.tscn")


remote func _show_error_to_others(error_text: String):
	_on_error_occurred(error_text)


remote func _remove_all_from_lobby():
	_on_error_occurred("The host has disconnected")
	_on_backed_out_of_lobby()


func _on_error_occurred(error_text: String):
	error_label.text = error_text
	print("AAAAAAAAAAHH2" + error_text)
	show_error_anim.play("anim")
	error_label_timer.start()


func _slide_out_error_label():
	show_error_anim.play_backwards("anim")
