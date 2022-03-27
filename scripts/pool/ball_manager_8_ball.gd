class_name BallManager8Ball
extends Node2D

var cue_ball: Ball
var balls_active: bool = false

onready var ball_placer: Node2D = $BallPlacer
onready var ball_holder: Node2D = $BallHolder
onready var ball_in_hand: BallInHand = $BallInHand


func initialize():
	ball_in_hand.initialize()
	ball_placer.place_balls(ball_holder)
	cue_ball = _get_cue_ball()
	if cue_ball == null:
		printerr("cue ball not found!")


func _physics_process(_delta):
	if balls_active:
		rpc_unreliable("_set_ball_states", _get_ball_states())


remote func _set_ball_states(states: Array):
	var balls: Array = ball_holder.get_children()
	print("balls size: ", balls.size(), " states size: ", states.size())
	if balls.size() != states.size():
		printerr("balls array is not the same size as states array!")
		return
	for i in range(balls.size()):
		balls[i].linear_velocity = Vector2.ZERO
		balls[i].global_position = states[i][0]
		balls[i].current_velocity = states[i][1]


func check_all_pocketed(type) -> bool:
	for ball in ball_holder.get_children():
		if !ball.is_queued_for_deletion() && ball.type == type:
			return false
	return true


func hit_cue_ball(impulse: Vector2):
	cue_ball.impulse = impulse


func hide_cue_ball():
	cue_ball.global_position = Globals.cue_ball_inactive_pos
	rpc_unreliable("_set_ball_states", _get_ball_states())


func update_ball_in_hand() -> bool:
	if cue_ball.global_position != Globals.cue_ball_inactive_pos:
		cue_ball.global_position = Globals.cue_ball_inactive_pos
		rpc_unreliable("_set_ball_states", _get_ball_states())
	var res = ball_in_hand.run()
	if res.placed:
		cue_ball.global_position = res.pos
		rpc_unreliable("_set_ball_states", _get_ball_states())
		return true
	return false


func remove(ball_: Ball):
	for ball in ball_holder.get_children():
		if ball == ball_:
			ball.queue_free()


func are_balls_still() -> bool:
	for ball in ball_holder.get_children():
		if ball.linear_velocity != Vector2.ZERO:
			return false
	return true


func _get_ball_states() -> Array:
	var states: Array = []
	for ball in ball_holder.get_children():
		states.append([ball.global_position, ball.current_velocity])
	return states


func _get_cue_ball() -> Ball:
	for ball in ball_holder.get_children():
		if ball.type == Enums.BallType.CUE:
			return ball
	return null
