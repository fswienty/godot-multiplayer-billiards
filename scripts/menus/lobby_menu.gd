extends Control

signal game_started
signal went_back
signal error_occurred(error_text)

var menu_open_anim: AnimationPlayer
var t1_empty_anim: AnimationPlayer
var t2_empty_anim: AnimationPlayer

var lobby_code_button_text: String

onready var t0_panel: PlayerContainer = get_node("%T0PlayerContainer")
onready var t1_panel: PlayerContainer = get_node("%T1PlayerContainer")
onready var t2_panel: PlayerContainer = get_node("%T2PlayerContainer")

onready var t1_button: Button = get_node("%T1JoinButton")
onready var t2_button: Button = get_node("%T2JoinButton")
onready var randomize_button: Button = get_node("%RandomizeButton")
onready var dummy_button: Button = get_node("%DummyButton")
onready var lobby_code_button: Button = get_node("%LobbyCodeButton")
onready var lobby_code_button_timer: Timer = lobby_code_button.get_node("Timer")
onready var waiting_label: Label = get_node("%WaitingLabel")
onready var start_button: Button = get_node("%StartButton")
onready var back_button: Button = get_node("%BackButton")

var __


func _ready():
	__ = Lobby.connect("player_infos_updated", self, "_on_player_infos_updated")
	__ = t1_button.connect("pressed", self, "_on_T1Button_pressed")
	__ = t2_button.connect("pressed", self, "_on_T2Button_pressed")
	__ = lobby_code_button.connect("pressed", self, "_on_LobbyCodeButton_pressed")
	__ = lobby_code_button_timer.connect("timeout", self, "_reset_lobby_code_button_text")
	__ = start_button.connect("pressed", self, "_on_StartButton_pressed")
	__ = randomize_button.connect("pressed", self, "_on_RandomizeButton_pressed")
	__ = back_button.connect("pressed", self, "_on_BackButton_pressed")

	t0_panel.title.text = "New Players"
	t1_panel.title.text = "Team 1"
	t2_panel.title.text = "Team 2"

	modulate = Color.transparent

	menu_open_anim = Animations.fade_in_anim(self, Globals.menu_transition_time)
	t1_empty_anim = Animations.indicate_error_anim(t1_panel)
	t2_empty_anim = Animations.indicate_error_anim(t2_panel)


func open():
	lobby_code_button_text = "Invite Code: " + Gotm.lobby.name
	lobby_code_button.text = lobby_code_button_text
	if get_tree().is_network_server():
		randomize_button.show()
		dummy_button.hide()
		start_button.show()
		waiting_label.hide()
	else:
		randomize_button.hide()
		dummy_button.show()
		start_button.hide()
		waiting_label.show()
	_on_player_infos_updated()
	show()
	menu_open_anim.play("anim")


func _on_player_infos_updated():
	# clear lists
	pass
	for label in t0_panel.list.get_children():
		t0_panel.list.remove_child(label)
		label.queue_free()
	for label in t1_panel.list.get_children():
		t1_panel.list.remove_child(label)
		label.queue_free()
	for label in t2_panel.list.get_children():
		t2_panel.list.remove_child(label)
		label.queue_free()
	# sort players into appropriate lists
	for info in Lobby.player_infos.values():
		var player_name = info.name
		var player_team = info.team
		var label = Label.new()
		label.clip_text = true
		label.text = str(player_name)
		if player_team == 1:
			t1_panel.list.add_child(label)
		elif player_team == 2:
			t2_panel.list.add_child(label)
		else:
			t0_panel.list.add_child(label)


func _on_T1Button_pressed():
	SoundManager.click()
	rpc_id(1, "_set_team", 1)


func _on_T2Button_pressed():
	SoundManager.click()
	rpc_id(1, "_set_team", 2)


func _on_LobbyCodeButton_pressed():
	SoundManager.click()
	OS.clipboard = Gotm.lobby.name
	lobby_code_button.text = "Copied to clipboard!"
	lobby_code_button_timer.start()


func _reset_lobby_code_button_text():
	lobby_code_button.text = lobby_code_button_text


func _on_StartButton_pressed():
	SoundManager.click()
	if Globals.DEBUG_MODE:
		rpc("_start_game")
	var can_start = Lobby.can_start_game()
	match can_start:
		-1:
			rpc("_start_game")
		1:
			t1_empty_anim.play("anim")
			emit_signal("error_occurred", "Team 1 is empty!")
		2:
			t2_empty_anim.play("anim")
			emit_signal("error_occurred", "Team 2 is empty!")


func _on_RandomizeButton_pressed():
	SoundManager.click()
	Lobby.randomize_players()


func _on_BackButton_pressed():
	SoundManager.click()
	Lobby.leave(get_tree().get_network_unique_id())
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("went_back")


remotesync func _start_game():
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("game_started")


remotesync func _set_team(team):
	var sender_id = get_tree().get_rpc_sender_id()
	Lobby.set_team(sender_id, team)
