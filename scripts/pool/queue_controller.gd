class_name QueueController
extends Node2D

signal queue_hit

export(float) var distance_at_rest: float = 15.0
export(float) var max_distance: float = 70.0
export(float) var force_mult = 1000.0

var cue_ball: Ball

# vars for direct control scheme
var dragged_distance: float = 0.0
var start_hold_distance: float = 0.0

# vars for two step control scheme
var is_second_step: bool = false

# vars for mouse wheel mode
var intensity: float = 0.0
var intensity_increment: float = 0.1

onready var queue: Sprite = $QueueSprite
onready var line: Line2D = $LineMask/Line2D


func initialize(cue_ball_: Ball):
	cue_ball = cue_ball_


func run():
	if cue_ball == null:
		printerr("missing cue ball!")
		return

	var state = []
	match Globals.queue_mode:
		Enums.QueueMode.DRAG:
			state = _drag_mode()
		Enums.QueueMode.MOUSE_WHEEL:
			state = _mouse_wheel_mode()

	if not state[0]:  # check if the queue has become invisible
		rpc("_set_state", state)
	else:
		rpc_unreliable("_set_state", state)


func _drag_mode() -> Array:
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
	if Input.is_action_just_released("lmb"):
		var impulse: Vector2 = (
			force_mult
			* (dragged_distance / max_distance)
			* -ball_to_mouse.normalized()
		)
		dragged_distance = 0
		visible_ = false
		if impulse != Vector2.ZERO:
			emit_signal("queue_hit", impulse)

	var queue_pos = ball_pos + (distance_at_rest + dragged_distance) * ball_to_mouse.normalized()
	var rot = ball_to_mouse.angle()
	return [visible_, queue_pos, rot + PI, ball_pos, rot - PI / 2]


func _mouse_wheel_mode() -> Array:
	var visible_: bool = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ball_pos: Vector2 = cue_ball.global_position
	var ball_to_mouse: Vector2 = mouse_pos - ball_pos

	if Input.is_action_just_released("mouse_wheel_up"):
		intensity += intensity_increment
	if Input.is_action_just_released("mouse_wheel_down"):
		intensity -= intensity_increment
	intensity = clamp(intensity, 0, 1)
	if Input.is_action_just_released("lmb"):
		var impulse: Vector2 = force_mult * intensity * ball_to_mouse.normalized()
		intensity = 0
		visible_ = false
		if impulse != Vector2.ZERO:
			emit_signal("queue_hit", impulse)

	var queue_pos = (
		ball_pos
		- (distance_at_rest + intensity * max_distance) * ball_to_mouse.normalized()
	)
	var rot = ball_to_mouse.angle()
	return [visible_, queue_pos, rot, ball_pos, rot + PI / 2]


remotesync func _set_state(state: Array):
	# set visibility
	self.visible = state[0]
	# set queue sprite
	queue.global_position = state[1]
	queue.rotation = state[2]
	# set line
	line.global_position = state[3]
	line.rotation = state[4]
