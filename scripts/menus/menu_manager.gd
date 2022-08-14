extends Node

var show_error_anim: AnimationPlayer

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false

onready var connect_menu = $ConnectMenu
onready var lobby_menu = $LobbyMenu
onready var error_label: Label = $ErrorLabel
onready var error_label_timer: Timer = $ErrorLabel/Timer
var _err


func _ready():
	_err = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
	_err = connect_menu.connect("error_occurred", self, "_on_error_occurred")
	_err = lobby_menu.connect("game_started", self, "_on_game_started")
	_err = lobby_menu.connect("went_back", self, "_on_backed_out_of_lobby")
	_err = lobby_menu.connect("error_occurred", self, "_on_error_occurred")
	_err = error_label_timer.connect("timeout", self, "_slide_out_error_label")

	show_error_anim = Animations.slide_in_anim(error_label, "y", 100, Globals.menu_transition_time)
	error_label.rect_position = Vector2(0, -1000)

	get_tree().refuse_new_network_connections = false
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
	lobby_menu.hide()
	connect_menu.open()


func _on_game_started():
	get_tree().refuse_new_network_connections = true
	print("game will be started with: ", Lobby.player_infos)

	# load game scene
	_err = get_tree().change_scene("res://scenes/EightBall.tscn")


func _on_error_occurred(error_text: String):
	error_label.text = error_text
	show_error_anim.play("anim")
	error_label_timer.start()


func _slide_out_error_label():
	show_error_anim.play_backwards("anim")
