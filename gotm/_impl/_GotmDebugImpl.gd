# MIT License
#
# Copyright (c) 2020-2022 Macaroni Studios AB
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name _GotmDebugImpl
#warnings-disable

static func _login() -> void:
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return
		
	_logout()
	
	g.user_id = _GotmImpl._generate_id()
	g.emit_signal("user_changed")


static func _logout() -> void:
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return
	
	if !g.has_user():
		return
		
	g.user_id = ""
	g.emit_signal("user_changed")


static func _add_lobby(lobby):
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return lobby
		
	lobby = _GotmImpl._add_lobby(lobby)
	lobby._impl.address = "127.0.0.1"
	lobby._impl.host_id = g.user._impl.id
	lobby.host._impl.id = g.user._impl.id
	lobby.peers = []
	return lobby
	

static func _remove_lobby(lobby) -> void:
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return
		
	_GotmImpl._leave_lobby(lobby)
	g._impl.lobbies.erase(lobby)


static func _clear_lobbies() -> void:
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return
	
	for lobby in g._impl.lobbies.duplicate():
		_remove_lobby(lobby)


static func _add_lobby_player(lobby, peer):
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return null
		
	peer.address = "127.0.0.1"
	peer._impl.id = peer._impl.id
	lobby.peers.push_back(peer)
	if lobby == g.lobby:
		lobby.emit_signal("peer_joined", peer)
	return peer


static func _remove_lobby_player(lobby, peer) -> void:
	var g = _GotmImpl._get_gotm()
	if g.is_live():
		return
	
	for p in lobby.peers.duplicate():
		if peer._impl.id != p._impl.id:
			continue
		if peer._impl.id == lobby.host._impl.id:
			_remove_lobby(lobby)
		else:
			lobby.peers.erase(p)
			if lobby == g.lobby:
				lobby.emit_signal("peer_left", p)
		
		
