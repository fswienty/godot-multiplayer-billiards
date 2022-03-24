class_name QueueController
extends Node2D

signal queue_hit

export(float) var distance_at_rest: float = 20.0
export(float) var max_distance: float = 200.0
export(float) var force_mult = 5

var dragged_distance: float = 0.0
var start_hold_distance: float = 0.0
var cue_ball: Ball

onready var queue: Sprite = $QueueSprite
onready var line: Line2D = $LineMask/Line2D


func initialize(cue_ball_: Ball):
	cue_ball = cue_ball_


func run():
	if cue_ball == null:
		printerr("missing cue ball!")
		return

	var visible_: bool = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ball_pos: Vector2 = cue_ball.global_position
	var ball_to_mouse: Vector2 = mouse_pos - ball_pos

	# handle dragging while lmb pressed
	if Input.is_action_just_pressed("lmb"):
		start_hold_distance = ball_to_mouse.length()
	if Input.is_action_pressed("lmb"):
		dragged_distance = ball_to_mouse.length() - start_hold_distance
		dragged_distance = clamp(dragged_distance, 0, max_distance)
	if Input.is_action_just_released("lmb") and dragged_distance > 0:
		var impulse: Vector2 = (
			force_mult
			* (dragged_distance / max_distance)
			* -ball_to_mouse.normalized()
		)
		dragged_distance = 0
		visible_ = false
		emit_signal("queue_hit", impulse)

	var queue_pos = ball_pos + (distance_at_rest + dragged_distance) * ball_to_mouse.normalized()
	var line_pos = ball_pos
	rpc_unreliable("_set_state", queue_pos, line_pos, ball_to_mouse.angle(), visible_)


remotesync func _set_state(queue_pos: Vector2, line_pos: Vector2, rot: float, visible_: bool):
	# set line
	line.global_position = line_pos
	line.rotation = -PI / 2 + rot
	# set queue sprite
	queue.global_position = queue_pos
	queue.rotation = PI + rot
	# set visibility
	self.visible = visible_
