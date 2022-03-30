extends Node

var processing: bool = false
var manager: GameManager8Ball

onready var current_player: Label = $Inset/CurrentPlayer/NameLabel/Name
onready var current_team: Label = $Inset/CurrentPlayer/TeamLabel/Team
onready var game_state: Label = $Inset/CurrentPlayer/GameStateLabel/GameState

onready var t1_ball_type: Label = $Inset/GeneralInfo/T1TypeLabel/T1Type
onready var t1_pocketed_balls: Label = $Inset/GeneralInfo/T1PocketedLabel/T1Pocketed
onready var t1_eight_target: Label = $Inset/GeneralInfo/T1EightTargetLabel/T1EightTarget
onready var t2_ball_type: Label = $Inset/GeneralInfo/T2TypeLabel/T2Type
onready var t2_pocketed_balls: Label = $Inset/GeneralInfo/T2PocketedLabel/T2Pocketed
onready var t2_eight_target: Label = $Inset/GeneralInfo/T2EightTargetLabel/T2EightTarget

onready var first_hit: Label = $Inset/TurnInfo/FirstHitLabel/FirstHit
onready var legal_pocketing: Label = $Inset/TurnInfo/LegalPocketingLabel/LegalPocketing
onready var fouled: Label = $Inset/TurnInfo/FouledLabel/Fouled
onready var first_hit_legal: Label = $Inset/TurnInfo/FirstHitLegalLabel/FirstHitLegal
onready var won: Label = $Inset/TurnInfo/WonLabel/Won
onready var lost: Label = $Inset/TurnInfo/LostLabel/Lost


func initialize(manager_: GameManager8Ball):
	manager = manager_
	processing = true


func _physics_process(_delta):
	if not processing:
		return

	if manager.t1_turn:
		current_team.text = "Team 1"
	else:
		current_team.text = "Team 2"
	current_player.text = Lobby.player_infos[manager.current_player_id].name
	game_state.text = Enums.GameState.keys()[manager.game_state]

	t1_ball_type.text = Enums.BallType.keys()[manager.t1_ball_type]
	t2_ball_type.text = Enums.BallType.keys()[manager.t2_ball_type]
	t1_pocketed_balls.text = str(manager.t1_pocketed_balls)
	t2_pocketed_balls.text = str(manager.t2_pocketed_balls)
	t1_eight_target.text = Enums.PocketLocation.keys()[manager.t1_8_ball_target]
	t2_eight_target.text = Enums.PocketLocation.keys()[manager.t2_8_ball_target]

	first_hit.text = Enums.BallType.keys()[manager.first_hit_type]
	legal_pocketing.text = str(manager.legal_pocketing)
	fouled.text = str(manager.has_fouled)
	first_hit_legal.text = str(manager._get_first_hit_legality())
	won.text = str(manager.has_won)
	lost.text = str(manager.has_lost)
