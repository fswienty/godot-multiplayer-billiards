class_name BallInHand
extends Area2D


func initialize():
	global_position = Vector2(9999990, 9999990)


func run() -> Dictionary:
	global_position = get_viewport().get_mouse_position()
	var body_count: int = get_overlapping_bodies().size()
	var area_count: int = get_overlapping_areas().size()

	rpc("_update", global_position)
	if Input.is_action_just_released("lmb"):
		if body_count + area_count == 0:
			return {"placed": true, "pos": global_position}
	return {"placed": false, "pos": Vector2.ZERO}


func remove():
	global_position = Vector2(9999990, 9999990)
	rpc("_update", global_position)


remote func _update(global_position_: Vector2):
	global_position = global_position_
