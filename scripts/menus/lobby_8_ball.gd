extends Control

onready var t0_list: VBoxContainer = $PlayerList/VBoxContainer
onready var t1_list: VBoxContainer = $T1List/VBoxContainer
onready var t2_list: VBoxContainer = $T2List/VBoxContainer
onready var t1_button: Button = $T1Button
onready var t2_button: Button = $T2Button
onready var randomize_button: Button = $RandomizeButton

onready var start_button = $StartButton
onready var waiting_label = $WaitingLabel

# onready var chat_enter = $ChatEnter
# onready var chat_display = $ChatDisplay

var _err = 0


func _ready():
	_err = Lobby.connect("player_infos_updated", self, "_on_player_infos_updated")


func enter():
	if get_tree().is_network_server():
		randomize_button.show()
		start_button.show()
		waiting_label.hide()
	else:
		randomize_button.hide()
		start_button.hide()
		waiting_label.show()
	update()


func _on_player_infos_updated(player_infos: Dictionary):
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
	for info in player_infos.values():
		var player_name = info.name
		var player_team = info.team
		var label = Label.new()
		label.text = str(player_name)
		if player_team == 1:
			t1_list.add_child(label)
		elif player_team == 2:
			t2_list.add_child(label)
		else:
			t0_list.add_child(label)


# func _on_ChatEnter_text_entered(new_text: String):
# 	if new_text == "":
# 		return
# 	chat_enter.clear()
# 	rpc("new_message", new_text)

# remotesync func new_message(message: String):
# 	var sender_id = get_tree().get_rpc_sender_id()
# 	var player_name
# 	if sender_id == get_tree().get_network_unique_id():
# 		player_name = Lobby.my_info.name
# 	else:
# 		player_name = Lobby.player_infos[sender_id].name
# 	chat_display.insert_text_at_cursor("\n")
# 	chat_display.insert_text_at_cursor(player_name + ": " + message)


func _on_T1Button_pressed():
	rpc_id(1, "_set_team", 1)


func _on_T2Button_pressed():
	rpc_id(1, "_set_team", 2)


func _on_RandomizeButton_pressed():
	Lobby.randomize_players()


func _on_StartButton_pressed():
	Lobby.host_started_game()


remotesync func _set_team(team):
	var sender_id = get_tree().get_rpc_sender_id()
	Lobby.set_team(sender_id, team)
