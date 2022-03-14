class_name BallInHand
extends Area2D


func initialize():
	global_position = Constants.ball_in_hand_inactive_pos


func run() -> Dictionary:
	rpc_unreliable("_set_global_position", get_viewport().get_mouse_position())

	var body_count: int = get_overlapping_bodies().size()
	var area_count: int = get_overlapping_areas().size()
	var area_free: bool = body_count + area_count == 0
	if Input.is_action_just_released("lmb") && area_free:
		var clicked_global_pos = global_position
		rpc("_set_global_position", Constants.ball_in_hand_inactive_pos)
		return {"placed": true, "pos": clicked_global_pos}
	return {"placed": false, "pos": Vector2.ZERO}


remotesync func _set_global_position(global_position_: Vector2):
	global_position = global_position_
