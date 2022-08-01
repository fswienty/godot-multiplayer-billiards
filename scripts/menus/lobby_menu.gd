extends Control

signal game_started

var menu_open_anim: AnimationPlayer

onready var t0_panel: PlayerContainer = $VBoxContainer/TeamPanelContainer/T0/PlayerContainer
onready var t1_panel: PlayerContainer = $VBoxContainer/TeamPanelContainer/T1/PlayerContainer
onready var t2_panel: PlayerContainer = $VBoxContainer/TeamPanelContainer/T2/PlayerContainer

onready var t1_button: Button = $VBoxContainer/TeamPanelContainer/T1/JoinButton
onready var t2_button: Button = $VBoxContainer/TeamPanelContainer/T2/JoinButton

onready var waiting_label = $VBoxContainer/ControlsContainer/WaitingLabel
onready var randomize_button: Button = $VBoxContainer/ControlsContainer/RandomizeButton
onready var start_button = $VBoxContainer/ControlsContainer/StartButton

var _err


func _ready():
	_err = Lobby.connect("player_infos_updated", self, "_on_player_infos_updated")
	_err = t1_button.connect("pressed", self, "_on_T1Button_pressed")
	_err = t2_button.connect("pressed", self, "_on_T2Button_pressed")
	_err = randomize_button.connect("pressed", self, "_on_RandomizeButton_pressed")
	_err = start_button.connect("pressed", self, "_on_StartButton_pressed")

	t0_panel.title.text = "New Players"
	t1_panel.title.text = "Team 1"
	t2_panel.title.text = "Team 2"

	modulate = Color.transparent
	menu_open_anim = Animations.fade_in_anim(self, Globals.menu_transition_time)


func open():
	if get_tree().is_network_server():
		randomize_button.show()
		start_button.show()
		waiting_label.hide()
	else:
		randomize_button.hide()
		start_button.hide()
		waiting_label.show()
	_on_player_infos_updated()
	menu_open_anim.play("anim")
	show()


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


func _on_RandomizeButton_pressed():
	SoundManager.click()
	Lobby.randomize_players()


func _on_StartButton_pressed():
	SoundManager.click()
	if Globals.DEBUG_MODE:
		rpc("_start_game")
	if Lobby.can_start_game():
		rpc("_start_game")


remotesync func _start_game():
	menu_open_anim.play_backwards("anim")
	yield(menu_open_anim, "animation_finished")
	emit_signal("game_started")


remotesync func _set_team(team):
	var sender_id = get_tree().get_rpc_sender_id()
	Lobby.set_team(sender_id, team)
