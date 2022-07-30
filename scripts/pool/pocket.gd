class_name Pocket
extends Area2D

enum PocketLocation { NONE, UP_LEFT, UP, UP_RIGHT, DOWN_LEFT, DOWN, DOWN_RIGHT }

export(PocketLocation) var location

onready var indicator = $Indicator
onready var indicator_anim: AnimationPlayer = $Indicator/AnimationPlayer


func _ready():
	indicator.visible = false


func indicate():
	indicator_anim.play("indicate")
