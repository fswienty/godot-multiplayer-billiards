extends Node

var _err


func get_anim(target_node: Node, animated_property: String, times: Array, values: Array) -> AnimationPlayer:
	if times.size() != values.size():
		push_error("times array and values array don't have the same size")
		return null

	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.length = times[-1]
	var path = "../" + target_node.name + ":" + animated_property
	animation.track_set_path(track_index, path)
	for i in range(times.size()):
		animation.track_insert_key(track_index, times[i], values[i])

	var player: AnimationPlayer = AnimationPlayer.new()
	player.name = target_node.name + "_" + animated_property + "_" + "AnimationPlayer"
	target_node.add_child(player)
	_err = player.add_animation("anim", animation)

	return player


func get_duration(player: AnimationPlayer) -> float:
	return player.get_animation("anim").length


func scale_anim(target_node: Control, t: float = 1, axis: String = "xy") -> AnimationPlayer:
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
	return get_anim(target_node, "rect_scale", [0, t], [v1, v2])


func fade_in_anim(target_node: Node, t: float = 1) -> AnimationPlayer:
	var v1 = Color.transparent
	var v2 = Color.white
	return get_anim(target_node, "modulate", [0, t], [v1, v2])


func indicate_error_anim(target_node: Control) -> AnimationPlayer:
	var initial_x = target_node.rect_position.x
	var initial_y = target_node.rect_position.y
	var times: Array = []
	var values: Array = []
	for i in range(6):
		times.append(i * 0.05)
	values.append(Vector2(initial_x, initial_y))
	values.append(Vector2(initial_x - 20, initial_y))
	values.append(Vector2(initial_x + 20, initial_y))
	values.append(Vector2(initial_x - 20, initial_y))
	values.append(Vector2(initial_x + 20, initial_y))
	values.append(Vector2(initial_x, initial_y))
	return get_anim(target_node, "rect_position", times, values)
