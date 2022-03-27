extends Node

var processing: bool = false
var manager: GameManager8Ball

var ball_container_scn = preload("res://scenes/ui_scenes/BallContainer.tscn")

onready var current_team: Label = $TopBarContainer/HBoxContainer/TeamLabel
onready var current_player: Label = $TopBarContainer/HBoxContainer/NameLabel
onready var ball_type: Label = $TopBarContainer/HBoxContainer/BallTypesContainer/BallTypeText

onready var next_player: Label = $BottomBarContainer/HBoxContainer/NextPlayerContainer/Text
onready var t1_pocketed: HBoxContainer = $BottomBarContainer/HBoxContainer/T1BallContainer
onready var t2_pocketed: HBoxContainer = $BottomBarContainer/HBoxContainer/T2BallContainer

var _err


func initialize(manager_: GameManager8Ball):
	manager = manager_
	_err = manager.connect("ball_pocketed", self, "_on_ball_pocketed")


func _physics_process(_delta):
	if not processing:
		return

	if manager.t1_turn:
		current_team.text = "Team 1"
		ball_type.text = _get_ball_type_text(manager.t1_ball_type, manager.t1_8_ball_target)
	else:
		current_team.text = "Team 2"
		ball_type.text = _get_ball_type_text(manager.t2_ball_type, manager.t2_8_ball_target)

	if manager.current_player_id >= 0:
		current_player.text = Lobby.player_infos[manager.current_player_id].name
	if manager.next_player_id >= 0:
		next_player.text = Lobby.player_infos[manager.next_player_id].name


func _get_ball_type_text(team_ball_type: int, team_8_ball_target: int) -> String:
	if team_8_ball_target == Enums.PocketLocation.NONE:
		match team_ball_type:
			Enums.BallType.FULL:
				return "Solids"
			Enums.BallType.HALF:
				return "Stripes"
			Enums.BallType.NONE:
				return "Undetermined"
			_:
				return "error, this should never be shown"
	else:
		return "Eight Ball " + Enums.PocketLocation.keys()[team_8_ball_target]


func _on_ball_pocketed():
	# clear old balls
	for child in t1_pocketed.get_children():
		t1_pocketed.remove_child(child)
		child.queue_free()
	for child in t2_pocketed.get_children():
		t2_pocketed.remove_child(child)
		child.queue_free()
	# add current balls
	for ball in manager.t1_pocketed_balls:
		var ball_container = ball_container_scn.instance()
		ball_container.get_node("TextureRect").texture = BallTextures.get_texture(ball)
		t1_pocketed.add_child(ball_container)
	for ball in manager.t2_pocketed_balls:
		var ball_container = ball_container_scn.instance()
		ball_container.get_node("TextureRect").texture = BallTextures.get_texture(ball)
		t2_pocketed.add_child(ball_container)
