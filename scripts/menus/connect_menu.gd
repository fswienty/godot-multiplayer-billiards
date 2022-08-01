extends Control

var player_name: String
var lobby_code: String

signal entered_lobby

var menu_open_anim: AnimationPlayer
var name_error_anim: AnimationPlayer
var lobby_code_error: AnimationPlayer

onready var player_input: LineEdit = $VBoxContainer/PlayerName
onready var lobby_input: LineEdit = $VBoxContainer/HBoxContainer/LobbyCode
onready var host_button = $VBoxContainer/HostButton
onready var join_button = $VBoxContainer/HBoxContainer/JoinButton

var _err


func _ready():
	_err = player_input.connect("text_changed", self, "_on_PlayerName_text_changed")
	_err = lobby_input.connect("text_changed", self, "_on_LobbyCode_text_changed")
	host_button.connect("pressed", self, "_on_HostButton_pressed")
	join_button.connect("pressed", self, "_on_JoinButton_pressed")

	menu_open_anim = Animations.fade_in_anim(self, "../ConnectMenu", Globals.menu_transition_time)
	name_error_anim = Animations.indicate_error_anim(
		player_input, "../ConnectMenu/VBoxContainer/PlayerName"
	)


func _on_PlayerName_text_changed(text: String):
	player_name = text


func _on_LobbyCode_text_changed(text: String):
	lobby_code = text


func _on_HostButton_pressed():
	SoundManager.click()
	if player_name == "":
		print("please enter a name")
		name_error_anim.play("anim")
		return
	Lobby.host(player_name)
	_transition_to_lobby()


func _on_JoinButton_pressed():
	SoundManager.click()
	if player_name == "":
		print("please enter a name")
		return
	if lobby_code.length() != 4:
		print("please enter a valid lobby code")
		return
	var success = yield(Lobby.join(player_name, lobby_code), "completed")
	if success:
		_transition_to_lobby()
	else:
		# TODO show error to user
		print("could not join lobby ", lobby_code)


func _transition_to_lobby():
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("entered_lobby")
