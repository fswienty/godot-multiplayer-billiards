extends Node

onready var head_spot = $HeadSpot
onready var foot_spot = $FootSpot


func get_head_spot() -> Vector2:
	return head_spot.position * self.scale


func get_foot_spot() -> Vector2:
	return foot_spot.position * self.scale
