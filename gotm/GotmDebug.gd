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

class_name GotmDebug
#warnings-disable

# Helper library for testing against the API locally, as if it would be live.
#
# These functions do not make real API calls. They fake operations and 
# trigger relevant signals as if they happened live.
#
# These functions do nothing when the game is running live on gotm.io.
# Running the game in the web player (gotm.io/web-player) also counts as live.

# Host a lobby without joining it.
# Note that the lobby is hidden by default and not fetchable with
# 'GotmLobbyFetch'. To make it fetchable, set 'hidden' to false.
# The lobby is only fetchable and joinable in this game process.
# Returns added lobby.
static func add_lobby() -> GotmLobby:
	return _GotmDebugImpl._add_lobby(GotmLobby.new())


# Remove a lobby created with 'add_lobby', as if its host (you) disconnected from it.
# Triggers 'lobby_changed' if you are in that lobby.
static func remove_lobby(lobby: GotmLobby) -> void:
	_GotmDebugImpl._remove_lobby(lobby)


# Remove all lobbies.
static func clear_lobbies() -> void:
	_GotmDebugImpl._clear_lobbies()


# Add yourself to the lobby, without joining it.
# Triggers 'peer_joined' if you are in that lobby.
# Returns joined peer.
static func add_lobby_peer(lobby: GotmLobby) -> GotmUser:
	return _GotmDebugImpl._add_lobby_player(lobby, GotmUser.new())


# Remove a peer created with 'add_lobby_peer' from the lobby, as if the peer (you) disconnected
# from the lobby. 
# Triggers 'peer_left' if you are in that lobby.
static func remove_lobby_peer(lobby: GotmLobby, peer: GotmUser) -> void:
	 _GotmDebugImpl._remove_lobby_player(lobby, peer)
