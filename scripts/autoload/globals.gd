extends Node

const ball_in_hand_inactive_pos: Vector2 = Vector2(9999990, 9999990)
const cue_ball_inactive_pos: Vector2 = Vector2(9999999, 9999999)

var DEBUG_MODE: bool = false
var DEBUG_HUD: bool = false


func get_anim(path: String, t1: float, v1, t2: float, v2) -> Animation:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_insert_key(track_index, t1, v1)
	animation.track_insert_key(track_index, t2, v2)
	return animation
