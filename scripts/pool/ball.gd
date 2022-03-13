class_name Ball
extends RigidBody2D

signal ball_pocketed
signal ball_hit

var number: int = -1
var type = Enums.BallType.NONE
var current_velocity: Vector2
var is_active: bool = false
var impulse: Vector2 = Vector2.ZERO


func initialize():
	_set_texture()
	_set_type()
	name = "Ball_" + str(number)


func _physics_process(_delta):
	if linear_velocity.length_squared() < 9:
		linear_velocity = Vector2.ZERO
	if is_active:
		apply_central_impulse(impulse)
		impulse = Vector2.ZERO
		current_velocity = linear_velocity


func _integrate_forces(_state):
	rotation_degrees = 0
	if is_active:
		rpc_unreliable("_set_state", global_position, current_velocity)


remote func _set_state(pos: Vector2, vel: Vector2):
	global_position = pos
	linear_velocity = Vector2.ZERO
	current_velocity = vel


func _set_texture():
	var texture
	match number:
		0:
			texture = BallTextures.tex_cue_ball
		1:
			texture = BallTextures.tex_yellow_full_1
		2:
			texture = BallTextures.tex_blue_full_2
		3:
			texture = BallTextures.tex_red_full_3
		4:
			texture = BallTextures.tex_purple_full_4
		5:
			texture = BallTextures.tex_orange_full_5
		6:
			texture = BallTextures.tex_green_full_6
		7:
			texture = BallTextures.tex_brown_full_7
		8:
			texture = BallTextures.tex_black_full_8
		9:
			texture = BallTextures.tex_yellow_half_9
		10:
			texture = BallTextures.tex_blue_half_10
		11:
			texture = BallTextures.tex_red_half_11
		12:
			texture = BallTextures.tex_purple_half_12
		13:
			texture = BallTextures.tex_orange_half_13
		14:
			texture = BallTextures.tex_green_half_14
		15:
			texture = BallTextures.tex_brown_half_15
		_:
			push_error("invalid ball number!")
	$Sprite.texture = texture


func _set_type():
	match number:
		0:
			type = Enums.BallType.CUE
		8:
			type = Enums.BallType.EIGHT
		1, 2, 3, 4, 5, 6, 7:
			type = Enums.BallType.FULL
		9, 10, 11, 12, 13, 14, 15:
			type = Enums.BallType.HALF
		_:
			push_error("invalid ball number!")


func _on_Ball_body_entered(body: Node):
	if body.is_in_group("ball"):
		var intensity = (current_velocity - linear_velocity).length()
		SoundManager.ball_hit(intensity)
		emit_signal("ball_hit", type, body.type)
	elif body.is_in_group("rail"):
		var intensity = (current_velocity - linear_velocity).length()
		SoundManager.rail_hit(intensity)
	else:
		print("Unhandled _on_Ball_body_entered() collision: ", body.name)


func _on_PocketDetector_area_entered(area: Area2D):
	if area.is_in_group("pocket"):
		SoundManager.pocket_hit()
		#TODO wut
		emit_signal("ball_pocketed", self, area as Pocket)
	else:
		print("Unhandled _on_PocketDetector_area_entered() event: ", area.name)
