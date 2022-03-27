extends Node

onready var tex_cue_ball = preload("res://assets/images/balls/cue_ball.png")
onready var tex_black_full_8 = preload("res://assets/images/balls/black_full_8.png")
onready var tex_blue_full_2 = preload("res://assets/images/balls/blue_full_2.png")
onready var tex_blue_half_10 = preload("res://assets/images/balls/blue_half_10.png")
onready var tex_brown_full_7 = preload("res://assets/images/balls/brown_full_7.png")
onready var tex_brown_half_15 = preload("res://assets/images/balls/brown_half_15.png")
onready var tex_green_full_6 = preload("res://assets/images/balls/green_full_6.png")
onready var tex_green_half_14 = preload("res://assets/images/balls/green_half_14.png")
onready var tex_orange_full_5 = preload("res://assets/images/balls/orange_full_5.png")
onready var tex_orange_half_13 = preload("res://assets/images/balls/orange_half_13.png")
onready var tex_purple_full_4 = preload("res://assets/images/balls/purple_full_4.png")
onready var tex_purple_half_12 = preload("res://assets/images/balls/purple_half_12.png")
onready var tex_red_full_3 = preload("res://assets/images/balls/red_full_3.png")
onready var tex_red_half_11 = preload("res://assets/images/balls/red_half_11.png")
onready var tex_yellow_full_1 = preload("res://assets/images/balls/yellow_full_1.png")
onready var tex_yellow_half_9 = preload("res://assets/images/balls/yellow_half_9.png")


func get_texture(number: int):
	match number:
		0:
			return tex_cue_ball
		1:
			return tex_yellow_full_1
		2:
			return tex_blue_full_2
		3:
			return tex_red_full_3
		4:
			return tex_purple_full_4
		5:
			return tex_orange_full_5
		6:
			return tex_green_full_6
		7:
			return tex_brown_full_7
		8:
			return tex_black_full_8
		9:
			return tex_yellow_half_9
		10:
			return tex_blue_half_10
		11:
			return tex_red_half_11
		12:
			return tex_purple_half_12
		13:
			return tex_orange_half_13
		14:
			return tex_green_half_14
		15:
			return tex_brown_half_15
		_:
			push_error("invalid ball number!")
			return tex_cue_ball
