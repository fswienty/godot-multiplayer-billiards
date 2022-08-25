extends Control

signal entered_lobby

var menu_open_anim: AnimationPlayer
var player_name_error_anim: AnimationPlayer
var lobby_code_error_anim: AnimationPlayer

onready var player_name_input: LineEdit = get_node("%PlayerNameLineEdit")
onready var lobby_code_input: LineEdit = get_node("%LobbyCodeLineEdit")
onready var host_button: Button = get_node("%HostButton")
onready var join_button: Button = get_node("%JoinButton")

var __


func _ready():
	__ = host_button.connect("pressed", self, "_on_HostButton_pressed")
	__ = join_button.connect("pressed", self, "_on_JoinButton_pressed")

	modulate = Color.transparent

	menu_open_anim = Animations.fade_in_anim(self, Globals.menu_transition_time)
	player_name_error_anim = Animations.indicate_error_anim(player_name_input)
	lobby_code_error_anim = Animations.indicate_error_anim(lobby_code_input)


func open():
	show()
	menu_open_anim.play("anim")


func _on_HostButton_pressed():
	SoundManager.click()
	if player_name_input.text == "":
		GlobalUi.show_error("Please enter a name")
		player_name_error_anim.play("anim")
		player_name_input.grab_focus()
		return
	Lobby.host(player_name_input.text)
	_transition_to_lobby()


func _on_JoinButton_pressed():
	SoundManager.click()
	if player_name_input.text == "":
		GlobalUi.show_error("Please enter a name")
		player_name_error_anim.play("anim")
		player_name_input.grab_focus()
		return
	if lobby_code_input.text.length() != 4:
		GlobalUi.show_error("Please enter a valid lobby code")
		lobby_code_error_anim.play("anim")
		lobby_code_input.grab_focus()
		return
	lobby_code_input.text = lobby_code_input.text.to_upper()
	var success = yield(Lobby.join(player_name_input.text, lobby_code_input.text), "completed")
	if success:
		_transition_to_lobby()
	else:
		GlobalUi.show_error("Lobby not found")
		lobby_code_error_anim.play("anim")
		lobby_code_input.caret_position = 999
		lobby_code_input.grab_focus()


func _transition_to_lobby():
	GlobalUi.hide_error()
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("entered_lobby")
