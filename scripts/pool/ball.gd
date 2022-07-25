class_name Ball
extends RigidBody2D

signal ball_pocketed
signal ball_hit

var number: int = -1
var type = Enums.BallType.NONE
var current_velocity: Vector2
var impulse: Vector2 = Vector2.ZERO


func initialize():
	_set_texture()
	_set_type()
	name = "Ball_" + str(number)


func _physics_process(_delta):
	if linear_velocity.length_squared() < 9:
		linear_velocity = Vector2.ZERO
	if impulse != Vector2.ZERO:
		apply_central_impulse(impulse)
		impulse = Vector2.ZERO
		current_velocity = linear_velocity


func _integrate_forces(_state):
	rotation_degrees = 0


func _set_texture():
	$Sprite.texture = BallTextures.get_texture(number)


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
		rpc("play_ball_hit_sound", intensity)
		emit_signal("ball_hit", type, body.type)
	elif body.is_in_group("rail"):
		var intensity = (current_velocity - linear_velocity).length()
		rpc("play_rail_hit_sound", intensity)
	else:
		print("Unhandled _on_Ball_body_entered() collision: ", body.name)


remotesync func play_ball_hit_sound(intensity: float):
	SoundManager.ball_hit(intensity)


remotesync func play_rail_hit_sound(intensity: float):
	SoundManager.rail_hit(intensity)


func _on_PocketDetector_area_entered(area: Area2D):
	if area.is_in_group("pocket"):
		SoundManager.pocket_hit()
		emit_signal("ball_pocketed", self, area as Pocket)
	else:
		print("Unhandled _on_PocketDetector_area_entered() event: ", area.name)
