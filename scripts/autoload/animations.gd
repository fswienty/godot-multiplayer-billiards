extends Node

var _err


func get_anim(target_node: Node, path: String, t1: float, v1, t2: float, v2) -> AnimationPlayer:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.length = t2
	animation.track_set_path(track_index, path)
	animation.track_insert_key(track_index, t1, v1)
	animation.track_insert_key(track_index, t2, v2)

	var player: AnimationPlayer = AnimationPlayer.new()
	player.name = path + "Animation"
	target_node.add_child(player)
	_err = player.add_animation("anim", animation)

	return player


func get_anim2(target_node: Node, path: String, times: Array, values: Array) -> AnimationPlayer:
	if times.size() != values.size():
		push_error("times array and values array don't have the same size")
		return null

	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.length = times[-1]
	animation.track_set_path(track_index, path)
	for i in range(times.size()):
		animation.track_insert_key(track_index, times[i], values[i])

	var player: AnimationPlayer = AnimationPlayer.new()
	player.name = path + "Animation"
	target_node.add_child(player)
	_err = player.add_animation("anim", animation)

	return player


func get_duration(player: AnimationPlayer) -> float:
	return player.get_animation("anim").length


func scale_anim(target_node: Node, path: String, t: float, axis: String) -> AnimationPlayer:
	var v1 = Vector2.ONE
	var v2 = Vector2.ONE
	match axis:
		"x":
			v1.x = 0
		"y":
			v1.y = 0
		"xy":
			v1.x = 0
			v1.y = 0
	return get_anim(target_node, path + ":rect_scale", 0, v1, t, v2)


func fade_in_anim(target_node: Node, path: String, t: float) -> AnimationPlayer:
	var v1 = Color.transparent
	var v2 = Color.white
	return get_anim(target_node, path + ":modulate", 0, v1, t, v2)


func indicate_error_anim(target_node: Node, path: String) -> AnimationPlayer:
	var times: Array = [0]
	var values: Array = [0]
	for i in range(6):
		pass
	return get_anim2(target_node, path + ":rect_position", times, values)
