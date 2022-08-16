extends Node

signal player_infos_updated

var player_infos: Dictionary = {}  # Player info, associate ID to data
var self_info: Dictionary = {name = "", team = 0}  # Info we send to other players

var __


func _ready():
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	__ = get_tree().connect("network_peer_connected", self, "_peer_connected")
	__ = get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	__ = get_tree().connect("connected_to_server", self, "_connected_ok")
	__ = get_tree().connect("connection_failed", self, "_connected_fail")
	__ = get_tree().connect("server_disconnected", self, "_server_disconnected")


# Called on both clients and server when a peer connects.
func _peer_connected(id):
	print("_peer_connected, id: ", id)


func _peer_disconnected(id):
	print("_peer_disconnected")
	__ = player_infos.erase(id)  # Erase player from info.
	emit_signal("player_infos_updated")


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


# called by a newly joined player on the server
remote func register_player(info: Dictionary):
	if get_tree().get_network_unique_id() == 1:
		# Get the id of the RPC sender.
		var id = get_tree().get_rpc_sender_id()
		player_infos[id] = info
		print("player joined with: ", info)
		rpc("update_player_infos", player_infos)
	else:
		print("This is a client, register_player() should never be called.")


# called by the server on all peers
remotesync func update_player_infos(player_infos_: Dictionary):
	player_infos = player_infos_
	# Call function to update lobby UI here
	emit_signal("player_infos_updated")


func host(player_name: String):
	# start gotm lobby
	__ = Gotm.host_lobby(false)
	var lobby_code = Random.generate_word(4).to_upper()
	Gotm.lobby.name = lobby_code
	Gotm.lobby.hidden = false

	# start godot server
	var peer = NetworkedMultiplayerENet.new()
	__ = peer.create_server(8070)
	get_tree().network_peer = peer
	player_infos[1] = {name = player_name, team = 0}  # manually add server to player_infos
	rpc("update_player_infos", player_infos)  # just to update self basically
	print("hosting lobby ", Gotm.lobby.name)


func join(player_name: String, lobby_name: String) -> bool:
	# join gotm lobby
	var fetch = GotmLobbyFetch.new()
	fetch.filter_name = lobby_name
	var lobbies = yield(fetch.first(), "completed")
	print("found lobbies: ", lobbies)
	if lobbies.size() == 0:
		print("lobby ", lobby_name, " not found")
		return false
	var success = yield(lobbies[0].join(), "completed")
	if not success:
		print("could not join lobby ", lobby_name)
		return false

	# join godot server
	var peer = NetworkedMultiplayerENet.new()
	__ = peer.create_client(Gotm.lobby.host.address, 8070)
	get_tree().network_peer = peer
	self_info.name = player_name
	print("joined lobby ", lobbies[0].name)
	return true


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


func can_start_game() -> int:
	var t1_count = 0
	var t2_count = 0

	for info in player_infos.values():
		if info.team == 1:
			t1_count += 1
		elif info.team == 2:
			t2_count += 1

	if t1_count < 1:
		print("Needs at least 1 player in t1!")
		return 1

	if t2_count < 1:
		print("Needs at least 1 player in t2!")
		return 2

	return -1
