extends Node

# UI
var _click_player: AudioStreamPlayer

# game sfx
var _ball_player: AudioStreamPlayer
var _last_ball_hit: int = 0
var _rail_player: AudioStreamPlayer
var _last_rail_hit: int = 0
var _pocket_player: AudioStreamPlayer

onready var _click_sound = preload("res://assets/audio/sfx/Click9.wav")
onready var _ball_sound = preload("res://assets/audio/sfx/ball_hit.wav")
onready var _rail_sound = preload("res://assets/audio/sfx/rail.wav")
onready var _pocket_sound = preload("res://assets/audio/sfx/pocket.wav")


func _ready():
	self.pause_mode = Node.PAUSE_MODE_PROCESS

	_click_player = AudioStreamPlayer.new()
	_click_player.stream = _click_sound
	add_child(_click_player)

	_ball_player = AudioStreamPlayer.new()
	_ball_player.stream = _ball_sound
	add_child(_ball_player)
	_rail_player = AudioStreamPlayer.new()
	_rail_player.stream = _rail_sound
	add_child(_rail_player)
	_pocket_player = AudioStreamPlayer.new()
	_pocket_player.stream = _pocket_sound
	add_child(_pocket_player)


func click():
	_click_player.volume_db = -10
	_click_player.play()


func ball_hit(intensity: float):
	if OS.get_ticks_msec() - _last_ball_hit < 30 or intensity == 0:
		return
	print("bonk! " + str(intensity))
	_ball_player.volume_db = _intensity_to_db(intensity, 500)
	_ball_player.pitch_scale = 1 + (2 * randf() - 1) / 100
	_last_ball_hit = OS.get_ticks_msec()
	_ball_player.play()


func rail_hit(intensity: float):
	if OS.get_ticks_msec() - _last_rail_hit < 30:
		return
	_rail_player.volume_db = -5 + _intensity_to_db(intensity, 500)
	_rail_player.pitch_scale = 1 + (2 * randf() - 1) / 100
	_last_ball_hit = OS.get_ticks_msec()
	_rail_player.play()


func pocket_hit():
	_pocket_player.play()


func _intensity_to_db(intensity: float, factor: float) -> float:
	var volume = -factor * (1 / (intensity + 1))
	return clamp(volume, -30, 0)
