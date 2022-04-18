extends Control

var player_name: String

signal entered_lobby

var menu_open_anim: AnimationPlayer

onready var player_input = $VBoxContainer/PlayerName
onready var host_button = $VBoxContainer/HostButton
onready var join_button = $VBoxContainer/JoinButton


func _ready():
	player_input.connect("text_changed", self, "_on_PlayerName_text_changed")
	host_button.connect("pressed", self, "_on_Button_pressed", ["host"])
	join_button.connect("pressed", self, "_on_Button_pressed", ["join"])

	menu_open_anim = Animations.fade_in_anim(self, "../ConnectMenu", Globals.menu_transition_time)


func _on_PlayerName_text_changed(name: String):
	player_name = name


func _on_Button_pressed(type: String):
	SoundManager.click()
	if player_name == "":
		print("please enter a name")
		return
	if type == "host":
		Lobby.host(player_name)
	elif type == "join":
		Lobby.join(player_name)
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("entered_lobby")
