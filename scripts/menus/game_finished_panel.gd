extends Control

onready var t1_team_label: GameFinishedTeamLabel = $VBoxContainer/HBoxContainer/T1Container/Team
onready var t2_team_label: GameFinishedTeamLabel = $VBoxContainer/HBoxContainer/T2Container/Team
onready var t1_list: VBoxContainer = $VBoxContainer/HBoxContainer/T1Container/Players
onready var t2_list: VBoxContainer = $VBoxContainer/HBoxContainer/T2Container/Players
onready var lobby_button: Button = $VBoxContainer/LobbyButton
onready var waiting_label: Label = $VBoxContainer/WaitingLabel

var _err


func initialize():
	hide()
	_err = lobby_button.connect("pressed", self, "_on_LobbyButton_pressed")
	t1_team_label.initialize("Team 1")
	t2_team_label.initialize("Team 2")
	# add players to lidsts
	for info in Lobby.player_infos.values():
		var player_name = info.name
		var player_team = info.team
		var label = Label.new()
		label.clip_text = true
		label.align = Label.ALIGN_CENTER
		label.text = str(player_name)
		if player_team == 1:
			t1_list.add_child(label)
		elif player_team == 2:
			t2_list.add_child(label)
	# show button or waiting label
	if get_tree().get_network_unique_id() == 1:
		lobby_button.show()
		waiting_label.hide()
	else:
		lobby_button.hide()
		waiting_label.show()


func display(t1_won: bool):
	get_tree().paused = true
	show()
	# show win animation
	if t1_won:
		print("t1 won!")
		t1_team_label.show_as_winner()
	else:
		print("t2 won!")
		t2_team_label.show_as_winner()


func _on_LobbyButton_pressed():
	SoundManager.click()
	# load lobby scene
	rpc("_back_to_lobby")


remotesync func _back_to_lobby():
	get_tree().paused = false
	_err = get_tree().change_scene("res://scenes/Menu.tscn")
