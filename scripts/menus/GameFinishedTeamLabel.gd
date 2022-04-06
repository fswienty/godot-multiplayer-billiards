extends HBoxContainer
class_name GameFinishedTeamLabel

onready var trophy_left: TextureRect = $TrophyLeft
onready var trophy_right: TextureRect = $TrophyRight
onready var team_label: Label = $Label


func initialize(team_name: String):
	team_label.text = team_name
	trophy_left.hide()
	trophy_right.hide()


func show_as_winner():
	trophy_left.show()
	trophy_right.show()
