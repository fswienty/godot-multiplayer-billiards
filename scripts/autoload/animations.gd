extends Node

var _err


func get_animation_player(target_node: Node, animated_property: String, times: Array, values: Array) -> AnimationPlayer:
	if times.size() != values.size():
		push_error("times array and values array are not the same size")
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
	var v1: Vector2
	match axis:
		"x":
			v1 = Vector2(0, 1)
		"y":
			v1 = Vector2(1, 0)
		"xy", _:
			v1 = Vector2(0, 0)
	return get_animation_player(target_node, "rect_scale", [0, t], [v1, Vector2.ONE])


func fade_in_anim(target_node: Node, t: float = 1) -> AnimationPlayer:
	var v1 = Color.transparent
	var v2 = Color.white
	return get_animation_player(target_node, "modulate", [0, t], [v1, v2])


func indicate_error_anim(target_node: Control, amplitude: float = 10, wiggle_count: int = 3) -> AnimationPlayer:
	var initial_x = target_node.rect_position.x
	var initial_y = target_node.rect_position.y
	var times: Array = []
	var values: Array = []
	for i in range(2 * wiggle_count + 2):
		times.append(i * 0.05)
	values.append(Vector2(initial_x, initial_y))
	for i in range(wiggle_count):
		values.append(Vector2(initial_x - amplitude, initial_y))
		values.append(Vector2(initial_x + amplitude, initial_y))
	values.append(Vector2(initial_x, initial_y))
	return get_animation_player(target_node, "rect_position", times, values)
