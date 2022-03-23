extends Node

var processing: bool = false
var manager: GameManager8Ball

onready var current_team: Label = $TopBarContainer/HBoxContainer/TeamLabel
onready var current_player: Label = $TopBarContainer/HBoxContainer/NameLabel
onready var ball_type: Label = $TopBarContainer/HBoxContainer/BallTypesContainer/BallTypeText


func initialize(manager_: GameManager8Ball):
	manager = manager_


func _physics_process(_delta):
	if not processing:
		return

	if manager.t1_turn:
		current_team.text = "Team 1"
		ball_type.text = _get_ball_type_text(manager.t1_ball_type, manager.t1_8_ball_target)
	else:
		current_team.text = "Team 2"
		ball_type.text = _get_ball_type_text(manager.t2_ball_type, manager.t2_8_ball_target)

	current_player.text = Lobby.player_infos[manager.current_player_id].name

	# t1_pocketed_balls.text = str(manager.t1_pocketed_balls)
	# t2_pocketed_balls.text = str(manager.t2_pocketed_balls)


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
