extends Node

const ball_in_hand_inactive_pos: Vector2 = Vector2(9999990, 9999990)
const cue_ball_inactive_pos: Vector2 = Vector2(9999999, 9999999)

const menu_transition_time: float = 0.3

var queue_mode = Enums.QueueMode.MOUSE_WHEEL

var DEBUG_MODE: bool = false
var DEBUG_HUD: bool = false
