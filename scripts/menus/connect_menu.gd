extends Control

var player_name: String
var lobby_code: String

signal entered_lobby

var menu_open_anim: AnimationPlayer
var player_name_error_anim: AnimationPlayer
var lobby_code_error_anim: AnimationPlayer

onready var player_input: LineEdit = $VBoxContainer/PlayerName
onready var lobby_input: LineEdit = $VBoxContainer/HBoxContainer/LobbyCode
onready var host_button: Button = $VBoxContainer/HostButton
onready var join_button: Button = $VBoxContainer/HBoxContainer/JoinButton

var _err


func _ready():
	_err = player_input.connect("text_changed", self, "_on_PlayerName_text_changed")
	_err = lobby_input.connect("text_changed", self, "_on_LobbyCode_text_changed")
	_err = host_button.connect("pressed", self, "_on_HostButton_pressed")
	_err = join_button.connect("pressed", self, "_on_JoinButton_pressed")

	menu_open_anim = Animations.fade_in_anim(self, Globals.menu_transition_time)
	player_name_error_anim = Animations.indicate_error_anim(player_input)
	lobby_code_error_anim = Animations.indicate_error_anim(lobby_input)


func _on_PlayerName_text_changed(text: String):
	player_name = text


func _on_LobbyCode_text_changed(text: String):
	lobby_code = text


func _on_HostButton_pressed():
	SoundManager.click()
	if player_name == "":
		print("please enter a name")
		player_name_error_anim.play("anim")
		return
	Lobby.host(player_name)
	_transition_to_lobby()


func _on_JoinButton_pressed():
	SoundManager.click()
	if player_name == "":
		print("please enter a name")
		player_name_error_anim.play("anim")
		return
	if lobby_code.length() != 4:
		print("please enter a valid lobby code")
		lobby_code_error_anim.play("anim")
		return
	var success = yield(Lobby.join(player_name, lobby_code), "completed")
	if success:
		_transition_to_lobby()
	else:
		lobby_code_error_anim.play("anim")
		print("could not join lobby ", lobby_code)


func _transition_to_lobby():
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("entered_lobby")
