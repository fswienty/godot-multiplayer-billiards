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
