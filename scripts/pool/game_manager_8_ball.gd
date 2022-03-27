class_name GameManager8Ball
extends Node

signal ball_pocketed

var processing: bool = false
var game_state = Enums.GameState.QUEUE
var self_id: int = 0

var has_fouled: bool = false
var legal_pocketing: bool = false
var has_won = false
var has_lost = false
var first_hit_type = Enums.BallType.NONE

var current_player_id: int = -1
var next_player_id: int = -1
var t1_turn = true
var t1_player_ids: Array = []
var t2_player_ids: Array = []
var t1_ball_type: int = Enums.BallType.NONE
var t2_ball_type: int = Enums.BallType.NONE
var t1_8_ball_target: int = Enums.PocketLocation.NONE
var t2_8_ball_target: int = Enums.PocketLocation.NONE
var t1_pocketed_balls: Array = []
var t2_pocketed_balls: Array = []

var _err

onready var ball_manager: BallManager8Ball = $BallManager
onready var queue_controller: QueueController = $QueueController


func _ready():
	initialize()


func initialize():
	print(Lobby.player_infos)
	self_id = get_tree().get_network_unique_id()
	if self_id == 1:
		randomize()
		var seed_ = randi()
		rpc("initialize_synced", Lobby.player_infos, seed_)


remotesync func initialize_synced(player_infos: Dictionary, seed_: int):
	seed(seed_)

	_err = queue_controller.connect("queue_hit", self, "_on_queue_hit")
	ball_manager.initialize()
	queue_controller.initialize(ball_manager.cue_ball)

	for key in player_infos.keys():
		var info = player_infos[key]
		if info.team == 1:
			t1_player_ids.append(key)
		elif info.team == 2:
			t2_player_ids.append(key)
		else:
			print("Invalid team for player ", info.name, ", team ", info.team)

	current_player_id = t1_player_ids.front()
	_hud_set_next_player()
	if self_id == current_player_id:
		game_state = Enums.GameState.QUEUE
	else:
		game_state = Enums.GameState.WAITING


func _physics_process(_delta):
	if not processing:
		return
	if game_state == Enums.GameState.WAITING:
		pass
	elif game_state == Enums.GameState.QUEUE:
		queue_controller.run()
	elif game_state == Enums.GameState.ROLLING:
		if ball_manager.are_balls_still():
			ball_manager.balls_active = false
			var legal_play = _get_first_hit_legality() && !has_fouled
			var go_again = legal_pocketing && legal_play
			rpc("_on_balls_stopped", has_won, has_lost, legal_play)
			if go_again:
				print("Go again!")
				game_state = Enums.GameState.QUEUE
			else:
				game_state = Enums.GameState.WAITING
				rpc("_on_turn_ended", legal_play)
	elif game_state == Enums.GameState.BALLINHAND:
		var placed: bool = ball_manager.update_ball_in_hand()
		if placed:
			game_state = Enums.GameState.QUEUE


func _set_next_player():
	if t1_turn:
		t1_player_ids.pop_front()
		t1_player_ids.push_back(current_player_id)
		var next_player = t2_player_ids.front()
		if next_player != null:
			current_player_id = next_player
	else:
		t2_player_ids.pop_front()
		t2_player_ids.push_back(current_player_id)
		var next_player = t1_player_ids.front()
		if next_player != null:
			current_player_id = next_player


func _hud_set_next_player():
	var t1_temp = [] + t1_player_ids
	var t2_temp = [] + t2_player_ids
	if t1_turn:
		t1_temp.pop_front()
		t1_temp.push_back(current_player_id)
		var next_player = t2_temp.front()
		if next_player != null:
			next_player_id = next_player
	else:
		t2_temp.pop_front()
		t2_temp.push_back(current_player_id)
		var next_player = t1_temp.front()
		if next_player != null:
			next_player_id = next_player
	print(next_player_id)


# called only on peer that takes the shot
func _on_queue_hit(impulse: Vector2):
	ball_manager.balls_active = true
	ball_manager.cue_ball.impulse = impulse
	game_state = Enums.GameState.ROLLING


# called on all peers including last active when their turn is over
remotesync func _on_turn_ended(legal_play: bool):
	_set_next_player()
	t1_turn = !t1_turn
	_hud_set_next_player()
	if self_id == current_player_id:
		if legal_play:
			game_state = Enums.GameState.QUEUE
		else:
			game_state = Enums.GameState.BALLINHAND


remotesync func _on_balls_stopped(has_won_: bool, has_lost_: bool, legal_play: bool):
	# check for game over
	if has_won_ and legal_play:
		print("WON!")
		return
	if (has_won_ and not legal_play) or has_lost_:
		print("LOST!")
		return
	# TODO: turn of processing, do stuff to show winnig or losing team, go back to lobby

	# reset for next turn
	has_fouled = false
	legal_pocketing = false
	has_won = false
	has_lost = false
	first_hit_type = Enums.BallType.NONE


func _get_first_hit_legality() -> bool:
	var hit_nothing: bool = first_hit_type == Enums.BallType.NONE
	var hit_eight: bool = first_hit_type == Enums.BallType.EIGHT
	var hit_wrong_type: bool = false
	var can_hit_eight: bool = t1_ball_type == Enums.BallType.NONE
	if t1_turn:
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
		ball_manager.hide_cue_ball()
		has_fouled = true
		return

	# handle 8 ball pocketed
	if ball.type == Enums.BallType.EIGHT:
		_handle_8_ball_pocketed(pocket)

	# handle first ball pocketed
	if t1_ball_type == Enums.BallType.NONE:
		_assign_ball_types(ball)

	# handle pocketing
	_handle_pocketing(ball)
	emit_signal("ball_pocketed")
	ball_manager.remove(ball)

	# check if the pocketed ball was the last non-8-ball for some team
	_check_last_non_8_ball(pocket)


func _handle_8_ball_pocketed(pocket: Pocket):
	if t1_turn:
		if t1_8_ball_target == pocket.location:
			has_won = true
		else:
			has_lost = true
	else:
		if t2_8_ball_target == pocket.location:
			has_won = true
		else:
			has_lost = true


func _assign_ball_types(ball: Ball):
	if ball.type == Enums.BallType.FULL:
		if t1_turn:
			t1_ball_type = Enums.BallType.FULL
			t2_ball_type = Enums.BallType.HALF
		else:
			t1_ball_type = Enums.BallType.HALF
			t2_ball_type = Enums.BallType.FULL
	elif ball.type == Enums.BallType.HALF:
		if t1_turn:
			t1_ball_type = Enums.BallType.HALF
			t2_ball_type = Enums.BallType.FULL
		else:
			t1_ball_type = Enums.BallType.FULL
			t2_ball_type = Enums.BallType.HALF
	else:
		printerr("cannot assign ", ball, " to a team")


func _handle_pocketing(ball: Ball):
	if ball.type == t1_ball_type:
		t1_pocketed_balls.push_front(ball.number)
		if t1_turn:
			legal_pocketing = true
		else:
			has_fouled = true
	elif ball.type == t2_ball_type:
		t2_pocketed_balls.push_front(ball.number)
		if not t1_turn:
			legal_pocketing = true
		else:
			has_fouled = true


func _get_opposite_pocket(pocket_location):
	if pocket_location == Enums.PocketLocation.UP_LEFT:
		return Enums.PocketLocation.DOWN_RIGHT
	elif pocket_location == Enums.PocketLocation.UP:
		return Enums.PocketLocation.DOWN
	elif pocket_location == Enums.PocketLocation.UP_RIGHT:
		return Enums.PocketLocation.DOWN_LEFT
	elif pocket_location == Enums.PocketLocation.DOWN_LEFT:
		return Enums.PocketLocation.UP_RIGHT
	elif pocket_location == Enums.PocketLocation.DOWN:
		return Enums.PocketLocation.UP
	elif pocket_location == Enums.PocketLocation.DOWN_RIGHT:
		return Enums.PocketLocation.UP_LEFT


func _check_last_non_8_ball(pocket: Pocket):
	var t1_all_pocketed: bool = ball_manager.check_all_pocketed(t1_ball_type)
	var t1_needs_8_target: bool = t1_8_ball_target == Enums.PocketLocation.NONE
	if t1_all_pocketed and t1_needs_8_target:
		t1_8_ball_target = _get_opposite_pocket(pocket.location)
		print("t1_all_pocketed: ", t1_all_pocketed and t1_needs_8_target)

	var t2_all_pocketed: bool = ball_manager.check_all_pocketed(t2_ball_type)
	var t2_needs_8_target: bool = t2_8_ball_target == Enums.PocketLocation.NONE
	if t2_all_pocketed and t2_needs_8_target:
		t2_8_ball_target = _get_opposite_pocket(pocket.location)
		print("t2_all_pocketed: ", t2_all_pocketed and t2_needs_8_target)


func _on_BallPlacer_ball_placed(ball: Ball):
	_err = ball.connect("ball_pocketed", self, "_on_ball_pocketed")
	_err = ball.connect("ball_hit", self, "_on_ball_hit")
