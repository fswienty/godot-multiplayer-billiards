class_name GameManager8Ball
extends Node

var game_state = Enums.GameState.NONE

var rounds_first_pocketing: bool = false
var has_fouled: bool = false
var legal_pocketing: bool = false
var has_won = false
var has_lost = false
var first_hit_type = Enums.BallType.NONE

var current_player_id: int = -1
var next_player_id: int = -1
var current_turn_number = 1
var t1_ball_type: int = Enums.BallType.NONE
var t2_ball_type: int = Enums.BallType.NONE
var t1_8_ball_target: int = Enums.PocketLocation.NONE
var t2_8_ball_target: int = Enums.PocketLocation.NONE
var t1_pocketed_balls: Array = []
var t2_pocketed_balls: Array = []

onready var table = $Table
onready var ball_manager: BallManager8Ball = $BallManager
onready var queue_controller: QueueController = $QueueController
onready var hud = $UI/Hud_8Ball
onready var debug_hud = $UI/DEBUG_Hud_8Ball
onready var game_finished_panel = $UI/GameFinished

var __


func _ready():
	if get_tree().get_network_unique_id() == 1:
		randomize()
		var seed_ = randi()
		rpc("initialize_synced", seed_)


remotesync func initialize_synced(seed_: int):
	print("setting common random seed")
	seed(seed_)

	# connect signals
	__ = ball_manager.ball_placer.connect("ball_placed", self, "_on_BallPlacer_ball_placed")
	__ = queue_controller.connect("queue_hit", self, "_on_queue_hit")

	# initialize nodes
	ball_manager.initialize()
	queue_controller.initialize(ball_manager.cue_ball)
	hud.initialize(self)
	debug_hud.hide()
	if Globals.DEBUG_HUD:
		$Background.hide()
		debug_hud.show()
		hud.hide()
		debug_hud.initialize(self)
	game_finished_panel.initialize()

	current_player_id = _get_player_id_for_turn(current_turn_number)
	next_player_id = _get_player_id_for_turn(current_turn_number + 1)
	hud.update()

	if get_tree().get_network_unique_id() == current_player_id:
		game_state = Enums.GameState.QUEUE
	else:
		game_state = Enums.GameState.WAITING

	if Globals.DEBUG_MODE:
		game_state = Enums.GameState.BALL_IN_HAND


func _physics_process(_delta):
	match game_state:
		Enums.GameState.WAITING:
			pass
		Enums.GameState.QUEUE:
			queue_controller.run()
		Enums.GameState.ROLLING:
			if ball_manager.are_balls_still():
				ball_manager.balls_active = false
				var legal_play = _get_first_hit_legality() && !has_fouled
				var go_again = legal_pocketing && legal_play
				rpc("_on_balls_stopped", has_won, has_lost, legal_play)
				if go_again:
					var indicate_target = t1_8_ball_target if is_t1_turn() else t2_8_ball_target
					table.indicate_8_ball_target(indicate_target)
					game_state = Enums.GameState.QUEUE
				else:
					game_state = Enums.GameState.WAITING
					rpc("_on_turn_ended", legal_play)
		Enums.GameState.BALL_IN_HAND:
			var placed: bool = ball_manager.update_ball_in_hand()
			if placed:
				game_state = Enums.GameState.QUEUE


func _get_player_id_for_turn(turn_number: int) -> int:
	var team_turn_number: int = int(ceil(turn_number as float / 2))
	var current_team: int = 1 if is_t1_turn(turn_number) else 2
	var team_player_ids: Array = []
	for key in Lobby.player_infos.keys():
		if Lobby.player_infos[key].team == current_team:
			team_player_ids.append(key)
	if team_player_ids.size() == 0:
		return current_player_id
	return team_player_ids[team_turn_number % team_player_ids.size()]


func is_t1_turn(turn_number: int = -1) -> bool:
	if turn_number == -1:
		return current_turn_number % 2 != 0
	else:
		return turn_number % 2 != 0


# called only on peer that takes the shot
func _on_queue_hit(impulse: Vector2):
	ball_manager.balls_active = true
	ball_manager.cue_ball.impulse = impulse
	game_state = Enums.GameState.ROLLING


# called on all peers including last active peer when their turn is over
remotesync func _on_turn_ended(legal_play: bool):
	current_turn_number += 1
	current_player_id = _get_player_id_for_turn(current_turn_number)
	next_player_id = _get_player_id_for_turn(current_turn_number + 1)
	hud.update()
	if get_tree().get_network_unique_id() == current_player_id:
		if legal_play:
			game_state = Enums.GameState.QUEUE
		else:
			game_state = Enums.GameState.BALL_IN_HAND


remotesync func _on_balls_stopped(has_won_: bool, has_lost_: bool, legal_play: bool):
	# check for game over
	if has_won_ and legal_play:
		game_finished_panel.display(1 if is_t1_turn() else 2)
		return
	if (has_won_ and not legal_play) or has_lost_:
		game_finished_panel.display(2 if is_t1_turn() else 1)
		return

	# reset for next turn
	has_fouled = false
	legal_pocketing = false
	has_won = false
	has_lost = false
	first_hit_type = Enums.BallType.NONE
	rounds_first_pocketing = false


func _get_first_hit_legality() -> bool:
	if rounds_first_pocketing:
		rounds_first_pocketing = false
		return true
	var hit_nothing: bool = first_hit_type == Enums.BallType.NONE
	var hit_eight: bool = first_hit_type == Enums.BallType.EIGHT
	var hit_wrong_type: bool = false
	var can_hit_eight: bool = t1_ball_type == Enums.BallType.NONE
	if is_t1_turn():
		if t1_8_ball_target != Enums.BallType.NONE:
			can_hit_eight = true
		if first_hit_type == t2_ball_type:
			hit_wrong_type = true
	else:
		if t2_8_ball_target != Enums.BallType.NONE:
			can_hit_eight = true
		if first_hit_type == t1_ball_type:
			hit_wrong_type = true
	if hit_nothing || hit_wrong_type || (hit_eight && !can_hit_eight):
		return false
	return true


func _on_ball_hit(type1, type2):
	# record first ball hit with cue ball
	if first_hit_type == Enums.BallType.NONE and type1 == Enums.BallType.CUE:
		first_hit_type = type2


func _on_ball_pocketed(ball: Ball, pocket: Pocket):
	print("Ball ", ball.number, " entered pocket ", Enums.PocketLocation.keys()[pocket.location])

	# handle cue ball pocketed
	if ball.type == Enums.BallType.CUE:
		ball_manager.hide_cue_ball = true
		has_fouled = true
		return

	# handle 8 ball pocketed
	if ball.type == Enums.BallType.EIGHT:
		_handle_8_ball_pocketed(pocket)

	# handle first ball pocketed
	if t1_ball_type == Enums.BallType.NONE:
		rounds_first_pocketing = true
		_assign_ball_types(ball)

	# handle pocketing
	_handle_pocketing(ball)
	hud.update()
	ball_manager.remove(ball)

	# check if the pocketed ball was the last non-8-ball for some team
	_check_last_non_8_ball(pocket)


func _handle_8_ball_pocketed(pocket: Pocket):
	if is_t1_turn():
		if pocket.location == t1_8_ball_target:
			has_won = true
		else:
			has_lost = true
	else:
		if pocket.location == t2_8_ball_target:
			has_won = true
		else:
			has_lost = true


func _assign_ball_types(ball: Ball):
	if is_t1_turn() and ball.type == Enums.BallType.FULL:
		t1_ball_type = Enums.BallType.FULL
		t2_ball_type = Enums.BallType.HALF
	elif is_t1_turn() and ball.type == Enums.BallType.HALF:
		t1_ball_type = Enums.BallType.HALF
		t2_ball_type = Enums.BallType.FULL
	elif not is_t1_turn() and ball.type == Enums.BallType.FULL:
		t2_ball_type = Enums.BallType.FULL
		t1_ball_type = Enums.BallType.HALF
	elif not is_t1_turn() and ball.type == Enums.BallType.HALF:
		t2_ball_type = Enums.BallType.HALF
		t1_ball_type = Enums.BallType.FULL


func _handle_pocketing(ball: Ball):
	if ball.type == t1_ball_type:
		t1_pocketed_balls.push_front(ball.number)
		if is_t1_turn():
			legal_pocketing = true
		else:
			has_fouled = true
	elif ball.type == t2_ball_type:
		t2_pocketed_balls.push_front(ball.number)
		if not is_t1_turn():
			legal_pocketing = true
		else:
			has_fouled = true


func _check_last_non_8_ball(pocket: Pocket):
	var t1_all_pocketed: bool = ball_manager.check_all_pocketed(t1_ball_type)
	var t1_needs_8_target: bool = t1_8_ball_target == Enums.PocketLocation.NONE
	if t1_all_pocketed and t1_needs_8_target:
		t1_8_ball_target = table.get_opposite_pocket(pocket.location)
		print("t1_all_pocketed: ", t1_all_pocketed and t1_needs_8_target)

	var t2_all_pocketed: bool = ball_manager.check_all_pocketed(t2_ball_type)
	var t2_needs_8_target: bool = t2_8_ball_target == Enums.PocketLocation.NONE
	if t2_all_pocketed and t2_needs_8_target:
		t2_8_ball_target = table.get_opposite_pocket(pocket.location)
		print("t2_all_pocketed: ", t2_all_pocketed and t2_needs_8_target)


func _on_BallPlacer_ball_placed(ball: Ball):
	__ = ball.connect("ball_pocketed", self, "_on_ball_pocketed")
	__ = ball.connect("ball_hit", self, "_on_ball_hit")
