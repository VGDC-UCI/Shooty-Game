"""
Script that handles the dedicated server information.

Author: Jacob Singleton
"""


extends Node


enum gamestate {
	PRE_GAME,
	IN_GAME,
	POST_GAME
}


const          _PORT: int = 10567
const   _MAX_PLAYERS: int = 12


var _network := NetworkedMultiplayerENet.new()
var _players: Dictionary = {}
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
	var player_list: Node = get_tree().current_scene.get_node("Players")
	
	player.set_name(str(player_id))
	
	player_list.add_child(player)
	
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
		var player: Node = _players[player_id]
		var player_list: Node = get_tree().current_scene.get_node("Players")
		
		player_list.remove_child(player_list.get_node(str(player_id)))
		_players.erase(player_id)
		
		if player.is_host() and len(_players) > 0:
			_players.values()[0].set_host(true)
			
			rpc("set_host", _get_host_id())
	
	rpc("disconnect_peer", player_id)


func _get_host_id() -> int:
	"""
	Returns the network id of the host.
	If there is no host, it returns 0.
	"""
	
	for player_id in _players:
		var player: Node = _players[player_id]
		
		if player.is_host():
			return player_id
	
	return 0


remote func get_all_players() -> Dictionary:
	"""
	Returns the dictionary of all players connected to the server.
	"""
	
	return _players


remote func setup_player(username: String) -> void:
	"""
	Sets the username of the player who is calling the function remotely.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	var player: Node = null
	
	if player_id in _players:
		player = _players[player_id]
	else:
		player = preload("res://src/main/game/Player.tscn").instance()
		
		player.set_name(str(player_id))
	
	player.set_username(username)
	rpc("connect_peer", player_id, username, player.is_host())
	rpc_id(player_id, "setup_complete")
	
	# Send the player who is done with setup the list of
	# players in the lobby currently.
	for peer_id in _players:
		if peer_id != player_id:
			var peer: Node = _players[peer_id]
			
			rpc_id(player_id, "connect_peer", peer_id, peer.get_username(), peer.is_host())


remote func chat_message(message: String) -> void:
	"""
	Sends a chat message to all clients connected in the lobby.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if _gamestate == gamestate.PRE_GAME:
		rpc("chat_message", player_id, message)


remote func start_game() -> void:
	"""
	Changes the gamestate from PRE_GAME to IN_GAME and relays
	to all clients that the game is starting.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if _get_host_id() == player_id:
		_gamestate = gamestate.IN_GAME
		
		rpc("start_game")


remote func player_movement(x: float, y: float) -> void:
	"""
	Sets the new position of the player and sends it to other clients.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_x(x)
		player.set_y(y)
		
		rpc_unreliable("peer_movement", player_id, x, y)


remote func change_facing_direction(facing_direction: int) -> void:
	"""
	Changes the facing direction of the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_facing_direction(facing_direction)
		
		rpc_unreliable("change_facing_direction", player_id, facing_direction)


remote func change_gun_position(gun_position: int) -> void:
	"""
	Changes the gun position of the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_gun_position(gun_position)
		
		rpc_unreliable("change_gun_position", player_id, gun_position)


remote func change_player_state(player_state: int) -> void:
	"""
	Changes the player state of the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_player_state(player_state)
		
		rpc_unreliable("change_player_state", player_id, player_state)


remote func change_x_input(x_input: float) -> void:
	"""
	Changes the x input of the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	if player_id in _players:
		var player: Node = _players[player_id]
		
		player.set_x_input(x_input)
		
		rpc_unreliable("change_x_input", player_id, x_input)


remote func bullet_shot(x_dir: float, y_dir: float) -> void:
	"""
	Shoots a bullet from the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	rpc_unreliable("bullet_shot", player_id, x_dir, y_dir)


remote func change_health(player_id: int, health: float, shield: float) -> void:
	"""
	Changes the health and shield of the given peer.
	"""
	
	rpc_unreliable("change_health", player_id, health, shield)


remote func change_kills(player_id: int, kills: int) -> void:
	"""
	Changes the kills of the given peer.
	"""
	
	rpc_unreliable("change_kills", player_id, kills)


remote func change_deaths(player_id: int, deaths: int) -> void:
	"""
	Changes the deaths of the given peer.
	"""
	
	rpc_unreliable("change_deaths", player_id, deaths)


remote func dash_particles() -> void:
	"""
	Sends dash particles for the given player.
	"""
	
	var player_id: int = get_tree().get_rpc_sender_id()
	
	rpc_unreliable("dash_particles", player_id)
