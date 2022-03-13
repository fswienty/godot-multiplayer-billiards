class_name BallManager8Ball
extends Node2D

var cue_ball: Ball
var balls_active: bool = false

onready var ball_placer: Node2D = $BallPlacer
onready var ball_holder: Node2D = $BallHolder
onready var ball_in_hand: BallInHand = $BallInHand


func initialize():
	ball_placer.place_balls(ball_holder)
	cue_ball = _get_cue_ball()
	ball_in_hand.global_position = Vector2(9999990, 9999990)


# func _physics_process(_delta):
# 	if balls_active:
# 		var states: Array = []
# 		for ball in ball_holder.get_children():
# 			states.append([ball.global_position, ball.current_velocity])
# 		rpc_unreliable("_set_ball_state", states)

# remote func _set_ball_state(states: Array):
# 	var balls: Array = ball_holder.get_children()
# 	if balls.size() != states.size():
# 		print("ERROR: balls array is not the same size as states array!")
# 		return
# 	for i in range(balls.size()):
# 		balls[i].linear_velocity = Vector2.ZERO
# 		balls[i].global_position = states[i][0]
# 		balls[i].current_velocity = states[i][1]


func check_all_pocketed(type) -> bool:
	for ball in ball_holder.get_children():
		if !ball.is_queued_for_deletion() && ball.type == type:
			return false
	return true


func hit_cue_ball(impulse: Vector2):
	cue_ball.impulse = impulse


func hide_cue_ball():
	cue_ball.is_active = true
	cue_ball.global_position = Vector2(9999999, 9999999)


func update_ball_in_hand() -> bool:
	var res = ball_in_hand.run()
	if res.placed:
		ball_in_hand.remove()
		cue_ball.global_position = res.pos
		return true
	return false


func remove(ball_: Ball):
	for ball in ball_holder.get_children():
		if ball == ball_:
			ball.queue_free()


func set_balls_active(is_active_: bool):
	# balls_active = is_active_
	for ball in ball_holder.get_children():
		ball.is_active = is_active_


func are_balls_still() -> bool:
	for ball in ball_holder.get_children():
		if ball.linear_velocity != Vector2.ZERO:
			return false
	return true


func _get_cue_ball() -> Ball:
	for ball in ball_holder.get_children():
		if ball.type == Enums.BallType.CUE:
			return ball
	return null
