class_name QueueController
extends Node

signal queue_hit

export(float) var distance_at_rest: float = 20.0
export(float) var max_distance: float = 200.0
export(float) var force_mult = 5

var dragged_distance: float = 0.0
var start_hold_distance: float = 0.0
var cue_ball: Ball

onready var queue_container: Node2D = $RotatingContainer
onready var queue: Sprite = $RotatingContainer/QueueSprite


func initialize(cue_ball_: Ball):
	cue_ball = cue_ball_


func run():
	if cue_ball == null:
		printerr("missing cue ball!")
		return
	queue_container.show()
	# get needed variables
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ball_pos: Vector2 = cue_ball.global_position
	var ball_to_mouse: Vector2 = mouse_pos - ball_pos
	# set container
	queue_container.global_position = ball_pos
	queue_container.rotation = PI + ball_to_mouse.angle()
	# set queue sprite
	queue.position.x = -distance_at_rest

	# handle dragging while lmb pressed
	if Input.is_action_just_pressed("lmb"):
		start_hold_distance = ball_to_mouse.length()
	if Input.is_action_pressed("lmb"):
		dragged_distance = ball_to_mouse.length() - start_hold_distance
		dragged_distance = clamp(dragged_distance, 0, max_distance)
		queue.position.x -= dragged_distance
	if Input.is_action_just_released("lmb") and dragged_distance > 0:
		var impulse: Vector2 = (
			force_mult
			* (dragged_distance / max_distance)
			* -ball_to_mouse.normalized()
		)
		queue_container.hide()
		emit_signal("queue_hit", impulse)
	rpc_unreliable("_set_state", queue.global_position, queue.rotation, queue_container.visible)


remote func _set_state(pos: Vector2, rot: float, visible: bool):
	queue.global_position = pos
	queue.rotation = rot
	queue_container.visible = visible
