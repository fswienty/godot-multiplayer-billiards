extends Control

onready var t1_team_label: GameFinishedTeamLabel = $VBoxContainer/HBoxContainer/T1Container/Team
onready var t2_team_label: GameFinishedTeamLabel = $VBoxContainer/HBoxContainer/T2Container/Team
onready var lobby_button: Button = $VBoxContainer/LobbyButton
onready var waiting_label: Label = $VBoxContainer/WaitingLabel

var _err


func initialize():
	hide()
	_err = lobby_button.connect("pressed", self, "_on_LobbyButton_pressed")
	t1_team_label.initialize("Team 1")
	t2_team_label.initialize("Team 2")
	if get_tree().get_network_unique_id() == 1:
		lobby_button.show()
		waiting_label.hide()
	else:
		lobby_button.hide()
		waiting_label.show()


func _on_LobbyButton_pressed():
	# load lobby scene
	_err = get_tree().change_scene("res://scenes/Menu.tscn")
