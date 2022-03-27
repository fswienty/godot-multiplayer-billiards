extends Node

export var DEBUG_MODE: bool = false
export var DEBUG_HUD: bool = false

var _err

onready var connect_menu = $UI/ConnectMenu
onready var lobby_8_ball = $UI/Lobby_8Ball
onready var DEBUG_hud_8_ball = $UI/DEBUG_Hud_8Ball
onready var hud_8_ball = $UI/Hud_8Ball
onready var game_8_ball = $Game_8Ball


func _ready():
	if DEBUG_MODE:
		connect_menu.player_name = "debug_host"
		connect_menu._on_HostButton_pressed()
		_on_game_started({1: {name = "debug_host", team = 1}})
		game_8_ball.game_state = Enums.GameState.BALLINHAND
	else:
		_err = connect_menu.connect("entered_lobby", self, "_on_entered_lobby")
		_err = Lobby.connect("game_started", self, "_on_game_started")
		connect_menu.show()
		lobby_8_ball.hide()
		DEBUG_hud_8_ball.hide()
		hud_8_ball.hide()
		game_8_ball.hide()
		game_8_ball.processing = false


func _on_entered_lobby():
	connect_menu.hide()
	lobby_8_ball.initialize()
	lobby_8_ball.show()
	DEBUG_hud_8_ball.hide()
	hud_8_ball.hide()


func _on_game_started(player_infos: Dictionary):
	print("game will be started with: ", player_infos)
	# remove menu
	connect_menu.hide()
	lobby_8_ball.hide()

	# load game scene
	game_8_ball.show()
	game_8_ball.initialize()
	game_8_ball.processing = true

	# init hud
	if DEBUG_HUD:
		hud_8_ball.hide()
		DEBUG_hud_8_ball.show()
		DEBUG_hud_8_ball.initialize(game_8_ball)
		DEBUG_hud_8_ball.processing = true
	else:
		hud_8_ball.show()
		hud_8_ball.initialize(game_8_ball)
		hud_8_ball.processing = true
