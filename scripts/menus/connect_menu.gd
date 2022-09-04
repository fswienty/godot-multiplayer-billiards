extends Control

signal entered_lobby

var player_name_error_anim: AnimationPlayer
var lobby_code_error_anim: AnimationPlayer
var drag_tab_title: String = "Drag"
var scroll_wheel_tab_title: String = "Scroll Wheel"

onready var player_name_input: LineEdit = $"%PlayerNameLineEdit"
onready var lobby_code_input: LineEdit = $"%LobbyCodeLineEdit"
onready var host_button: Button = $"%HostButton"
onready var join_button: Button = $"%JoinButton"
onready var controls_tab: TabContainer = $"%ControlSchemeTabContainer"

var __


func _ready():
	__ = host_button.connect("pressed", self, "_on_HostButton_pressed")
	__ = join_button.connect("pressed", self, "_on_JoinButton_pressed")
	__ = controls_tab.connect("tab_changed", self, "_on_ControlsTab_tab_changed")

	controls_tab.set_tab_title(0, drag_tab_title)
	controls_tab.set_tab_title(1, scroll_wheel_tab_title)

	modulate = Color.transparent

	player_name_error_anim = Animations.indicate_error_anim(player_name_input)
	lobby_code_error_anim = Animations.indicate_error_anim(lobby_code_input)


func _on_HostButton_pressed():
	SoundManager.click()
	if not _validate_player_name():
		return
	Lobby.host(player_name_input.text)
	emit_signal("entered_lobby")


func _on_JoinButton_pressed():
	SoundManager.click()
	if not _validate_player_name():
		return
	if lobby_code_input.text.length() != 4:
		GlobalUi.show_error("Please enter a valid lobby code")
		lobby_code_error_anim.play("anim")
		lobby_code_input.grab_focus()
		return
	lobby_code_input.text = lobby_code_input.text.to_upper()
	var success = yield(Lobby.join(player_name_input.text, lobby_code_input.text), "completed")
	if success:
		emit_signal("entered_lobby")
	else:
		GlobalUi.show_error("Lobby not found")
		lobby_code_error_anim.play("anim")
		lobby_code_input.caret_position = 999
		lobby_code_input.grab_focus()


# Strips player name of white space and shows error if needed.
# Returns true if name is valid, otherwise false
func _validate_player_name() -> bool:
	player_name_input.text = player_name_input.text.strip_escapes().strip_edges()
	if player_name_input.text == "":
		GlobalUi.show_error("Please enter a valid name")
		player_name_error_anim.play("anim")
		player_name_input.grab_focus()
		return false
	if Utils.contains_bad_word(player_name_input.text):
		GlobalUi.show_error("Please use another name")
		player_name_error_anim.play("anim")
		player_name_input.grab_focus()
		player_name_input.clear()
		return false
	return true


func _on_ControlsTab_tab_changed(tab: int) -> void:
	var tab_title: String = controls_tab.get_tab_title(tab)
	match tab_title:
		drag_tab_title:
			Globals.queue_mode = Enums.QueueMode.DRAG
		scroll_wheel_tab_title:
			Globals.queue_mode = Enums.QueueMode.MOUSE_WHEEL
