extends Node

signal player_infos_updated

var player_infos: Dictionary = {}  # Player info, associate ID to data
var self_info: Dictionary = {name = "", team = 0}  # Info we send to other players
var peer: NetworkedMultiplayerENet

var _err


func _ready():
	peer = NetworkedMultiplayerENet.new()

	_err = get_tree().connect("network_peer_connected", self, "_peer_connected")
	_err = get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	_err = get_tree().connect("connected_to_server", self, "_connected_ok")
	_err = get_tree().connect("connection_failed", self, "_connected_fail")
	_err = get_tree().connect("server_disconnected", self, "_server_disconnected")


# Called on both clients and server when a peer connects.
func _peer_connected(id):
	print("_peer_connected, id: ", id)


func _player_disconnected(id):
	print("_player_disconnected")
	_err = player_infos.erase(id)  # Erase player from info.
	emit_signal("players_updated")


# Only called on clients, not server.
func _connected_ok():
	print("_connected_ok")
	# send the peer's info to the  server
	rpc_id(1, "register_player", self_info)


# Server kicked us; show error and abort.
func _server_disconnected():
	print("_server_disconnected")


# Could not even connect to server; abort.
func _connected_fail():
	print("_connected_fail")


remote func register_player(info: Dictionary):
	if get_tree().get_network_unique_id() == 1:
		# Get the id of the RPC sender.
		var id = get_tree().get_rpc_sender_id()
		player_infos[id] = info
		print("player joined with: ", info)
		rpc("update_player_infos", player_infos)
	else:
		print("This is a client, register_player() should never be called.")


remotesync func update_player_infos(player_infos_: Dictionary):
	player_infos = player_infos_
	# Call function to update lobby UI here
	emit_signal("player_infos_updated", player_infos)


func host(player_name: String):
	_err = peer.create_server(8070)
	get_tree().network_peer = peer
	player_infos[1] = {name = player_name, team = 0}  # manually add server to player_infos
	rpc("update_player_infos", player_infos)  # just to update self basically
	print("hosting...")


func join(player_name: String):
	_err = peer.create_client("127.0.0.1", 8070)
	get_tree().network_peer = peer
	self_info.name = player_name
	print("joining...")


func set_team(player_id, team):
	player_infos[player_id].team = team
	rpc("update_player_infos", player_infos)


func randomize_players():
	var player_ids: Array = player_infos.keys()
	player_ids.shuffle()
	var team: int = randi() % 2
	for id in player_ids:
		player_infos[id].team = team + 1
		team = (team + 1) % 2
	rpc("update_player_infos", player_infos)


func can_start_game():
	var t1_count = 0
	var t2_count = 0

	for info in player_infos.values():
		if info.team == 1:
			t1_count += 1
		elif info.team == 2:
			t2_count += 1

	if t1_count < 1 or t2_count < 1:
		print("Needs at least 1 player per team!")
		return false

	return true
