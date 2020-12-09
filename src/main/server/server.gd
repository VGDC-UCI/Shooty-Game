"""
Script that handles the dedicated server information.

Author: Jacob Singleton
"""


extends Node


const          _PORT: int = 10567
const   _MAX_PLAYERS: int = 12

var _network := NetworkedMultiplayerENet.new()
var _players: Dictionary = {}

enum gamestate {
	PRE_GAME,
	IN_GAME,
	POST_GAME
}

var _gamestate: int = gamestate.PRE_GAME


func _ready() -> void:
	"""
	Called when the server first starts.
	Starts the dedicated server.
	"""
	
	_start_server()


func _start_server() -> void:
	"""
	Sets up the server network with signal connections.
	"""
	
	_network.create_server(_PORT, _MAX_PLAYERS)
	
	get_tree().set_network_peer(_network)
	
	_network.connect("peer_connected", self, "_on_player_connected")
	_network.connect("peer_disconnected", self, "_on_player_disconnected")
	
	print('Started dedicated server for Shooty Game.')


func _on_player_connected(player_id: int) -> void:
	"""
	Called when a player is connecting to the server.
	Connects the given player to the server.
	"""
	
	print('Player (' + str(player_id) + ') connected.')
	
	var player = preload("res://src/main/game/Player.tscn").instance()
	
	player.set_name(str(player_id))
	player.set_username(str(player_id))
	
	_get_current_scene().get_node("Players").add_child(player)
	
	if not player_id in _players:
		if len(_players) == 0:
			player.set_host(true)
		
		_players[player_id] = player
	
	rpc("set_host", _get_host_id())


func _on_player_disconnected(player_id: int) -> void:
	"""
	Called when a player disconnects from the server.
	"""
	
	print('Player (' + str(player_id) + ') disconnected.')
	
	if player_id in _players:
		_get_current_scene().get_node("Players").remove_child(_get_current_scene().get_node("Players/" + str(player_id)))
		_players.erase(player_id)
	
	rpc("disconnect_player", player_id)
	
	if _get_host_id() == 0 and len(_players) > 0:
		_players.values()[0].set_host(true)
		rpc("set_host", _get_host_id())


func _get_host_id() -> int:
	"""
	Returns the network id of the host.
	"""
	
	for player_id in _players:
		var player: Node = _players[player_id]
		
		if player.is_host():
			return player_id
	
	return 0


func _get_current_scene() -> Node:
	"""
	Returns the current scene in the game.
	"""
	
	return get_tree().current_scene


remote func get_all_players() -> Dictionary:
	"""
	Returns the dictionary of all players connected to the server.
	"""
	
	return _players


remote func change_username(player_id: int, username: String) -> void:
	"""
	Sets the username of the player who is calling the function remotely.
	"""
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_username(username)
		
		rpc("connect_peer", player_id, username, player.is_host())
	
	for id in _players:
		var player: Node = _players[id]
		
		rpc_id(player_id, "connect_peer", id, player.get_username(), player.is_host())
	
	rpc_id(player_id, "done_configuring")


remote func send_chat_message(player_id: int, message: String) -> void:
	"""
	Relays chat message to clients connected.
	"""
	
	rpc("send_chat_message", player_id, message)
