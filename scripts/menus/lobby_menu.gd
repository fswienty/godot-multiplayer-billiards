extends Control

signal game_started

var menu_open_anim: AnimationPlayer

onready var t0_list: VBoxContainer = $VBoxContainer/TeamPanelContainer/T0/PlayerContainer/VBoxContainer
onready var t1_list: VBoxContainer = $VBoxContainer/TeamPanelContainer/T1/PlayerContainer/VBoxContainer
onready var t2_list: VBoxContainer = $VBoxContainer/TeamPanelContainer/T2/PlayerContainer/VBoxContainer
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

	modulate = Color.transparent
	menu_open_anim = Animations.fade_in_anim(self, "../LobbyMenu", Globals.menu_transition_time)


func open():
	if get_tree().is_network_server():
		randomize_button.show()
		start_button.show()
		waiting_label.hide()
	else:
		randomize_button.hide()
		start_button.hide()
		waiting_label.show()
	update()
	menu_open_anim.play("anim")
	show()


func _on_player_infos_updated():
	# clear lists
	for label in t0_list.get_children():
		t0_list.remove_child(label)
		label.queue_free()
	for label in t1_list.get_children():
		t1_list.remove_child(label)
		label.queue_free()
	for label in t2_list.get_children():
		t2_list.remove_child(label)
		label.queue_free()
	# sort players into appropriate lists
	for info in Lobby.player_infos.values():
		var player_name = info.name
		var player_team = info.team
		var label = Label.new()
		label.clip_text = true
		label.text = str(player_name)
		if player_team == 1:
			t1_list.add_child(label)
		elif player_team == 2:
			t2_list.add_child(label)
		else:
			t0_list.add_child(label)


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
