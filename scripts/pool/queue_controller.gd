class_name QueueController
extends Node

signal queue_hit

const distance_at_rest: float = 20.0
const force_to_distance: float = 1.0

export(int) var force_mult = 3

var force: float = 0.0
var lmb_pressed: bool = false
var start_hold_distance: float = 0.0
var cue_ball: Ball
var ball_holder: Node2D

onready var queue: Sprite = $QueueSprite


func initialize(cue_ball_: Ball):
	cue_ball = cue_ball_


func run():
	if cue_ball == null:
		printerr("missing cue ball!")
		return
	queue.show()
	# get needed variables
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ball_pos: Vector2 = cue_ball.global_position
	var ball_to_mouse: Vector2 = mouse_pos - ball_pos
	# set position
	queue.global_position = ball_pos + distance_at_rest * ball_to_mouse.normalized()
	# set rotation
	queue.rotation = PI + ball_to_mouse.angle()

	# get force when dragging mouse while clicked
	if Input.is_action_just_pressed("lmb"):
		start_hold_distance = ball_to_mouse.length()
	if Input.is_action_pressed("lmb"):
		force = ball_to_mouse.length() - start_hold_distance
		force = clamp(force, 0, 200)
		queue.position += force_to_distance * force * ball_to_mouse.normalized()
	if Input.is_action_just_released("lmb") and force > 0:
		var impulse: Vector2 = force_mult * force * -ball_to_mouse.normalized()
		queue.hide()
		emit_signal("queue_hit", impulse)
	rpc_unreliable("_set_state", queue.global_position, queue.rotation, queue.visible)


remote func _set_state(pos: Vector2, rot: float, visible: bool):
	queue.global_position = pos
	queue.rotation = rot
	queue.visible = visible
