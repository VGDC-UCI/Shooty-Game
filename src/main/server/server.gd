"""
Script that handles the client's connection to the server.

Author: Jacob Singleton
"""


extends Node


enum gamestate {
	PRE_GAME,
	IN_GAME,
	POST_GAME
}


const _MULTIPLAYER_SCENE_PATH: String = "res://src/main/menus/multiplayer/Multiplayer.tscn"
const _LOBBY_SCENE_PATH: String = "res://src/main/menus/lobby/Lobby.tscn"
const _GAME_SCENE_PATH: String = "res://src/main/game/world/World.tscn"

const MAIN_HOST: String = "127.0.0.1"
const MAIN_PORT: int    = 10567


var disconnect_reason = null

var _network := NetworkedMultiplayerENet.new()
var _players: Dictionary = {}
var _gamestate: int = gamestate.PRE_GAME

var player_config = {
	"name" : "The Warrior",
	"class_id" : 0,
	"input_id" : 0,
	"team" : 1
}


func connect_to_server(host: String, port: int, player: Node) -> bool:
	"""
	Connects the player to the server given the host and port.
	Returns whether the connection was successful.
	"""
	
	if _network.create_client(host, port) == OK:
		get_tree().set_network_peer(_network)
		
		var player_id: int = get_tree().get_network_unique_id()
		
		player.set_name(str(player_id))
		_players[player_id] = player
		
		_network.connect("connection_succeeded", self, "_on_connection_succeeded")
		_network.connect("connection_failed", self, "_on_connection_failed")
		_network.connect("server_disconnected", self, "_on_server_disconnect")
	
		print('Connecting to "' + host + ':' + str(port) + '"')
		
		return true
	else:
		print('Unable to connect to "' + host + ':' + str(port) + '"')
		
		return false


func get_root_player() -> Node:
	"""
	Returns the root player of the game.
	"""
	
	var player_id: int = get_tree().get_network_unique_id()
	
	if player_id in _players:
		return _players[player_id]
	else:
		print('Unable to get root player')
		return null


func _on_connection_succeeded() -> void:
	"""
	Called when the player successfully connected to the server.
	"""
	
	var root_player: Node = get_root_player()
	
	if root_player == null:
		print("Error syncing player data to the server.")
		
		disconnect_reason = "Error syncing player data to the server."
		disconnect_from_server()
	else:
		rpc_id(1, "setup_player", root_player.get_username())
		
		print('Connection succeeded.')


func _on_connection_failed() -> void:
	"""
	Called when the player failed to connect to the server.
	"""
	
	print('Connection failed.')


func _on_server_disconnect() -> void:
	"""
	Called when the server has been closed.
	"""
	
	disconnect_reason = "Server has been closed."
	disconnect_from_server()


func disconnect_from_server() -> void:
	"""
	Disconnects the client from the server.
	"""
	
	get_tree().change_scene(_MULTIPLAYER_SCENE_PATH)
	get_tree().set_network_peer(null)
	
	_network = NetworkedMultiplayerENet.new()
	_players = {}
	_gamestate = gamestate.PRE_GAME


func get_players():
	"""
	Returns the list of players connected to the game.
	"""
	
	return _players.values()


remote func setup_complete() -> void:
	"""
	Called when the player connecting to the server is done being
	setup by the server.
	"""
	
	get_tree().change_scene(_LOBBY_SCENE_PATH)


remote func connect_peer(peer_id: int, username: String, host: bool) -> void:
	"""
	RPC Call sent by the server to connect a peer player.
	"""
	
	if peer_id != get_tree().get_network_unique_id():
		var player: Node = preload("res://src/main/menus/lobby/player/LobbyPlayer.tscn").instance()
		
		player.set_name(str(peer_id))
		player.set_username(username)
		player.set_host(host)
		
		if host:
			player.set_text(username + " (Host)")
		else:
			player.set_text(username)
		
		var current_scene: Node = get_tree().current_scene
		
		if current_scene.get_name() == "Lobby":
			var player_list: Node = current_scene.get_node("Content/CenterBackground/Center/Players/PlayerList")
			
			player_list.add_child(player)
		
		_players[peer_id] = player


remote func disconnect_peer(player_id: int) -> void:
	"""
	Disconnects the given peer player id connection.
	"""
	
	var current_scene: Node = get_tree().current_scene
	
	if player_id in _players:
		if current_scene.get_name() == "Lobby":
			var player_list: Node = current_scene.get_node("Content/CenterBackground/Center/Players/PlayerList")
			
			if _player_id_in_player_list(player_id, player_list):
				player_list.remove_child(player_list.get_node(str(player_id)))
		
		_players.erase(player_id)


remote func set_host(player_id: int) -> void:
	"""
	Sets the host to the given player id and removes it from everyone else.
	"""
	
	if _gamestate == gamestate.PRE_GAME:
		var current_scene: Node = get_tree().current_scene
		
		for id in _players:
			var player: Node = _players[id]
			
			if id != player_id and player.is_host():
				player.set_host(false)
				
				if player_id == get_tree().get_network_unique_id():
					player.set_text(player.get_username() + " (You)")
				else:
					player.set_text(player.get_username())
				
				if current_scene.get_name() == "Lobby":
					current_scene.get_node("Content/Buttons/StartButton").set_visible(false)
			
			if id == player_id and not player.is_host():
				player.set_host(true)
				
				if player_id == get_tree().get_network_unique_id():
					player.set_text(player.get_username() + " (You) (Host)")
				else:
					player.set_text(player.get_username() + " (Host)")
				
				if current_scene.get_name() == "Lobby":
					current_scene.get_node("Content/Buttons/StartButton").set_visible(true)


func _player_id_in_player_list(player_id: int, player_list: Node) -> bool:
	"""
	Returns true if the given player id is in the given PlayerList node.
	"""
	
	for child in player_list.get_children():
		if int(child.get_name()) == player_id:
			return true
	
	return false


remote func send_chat_message(player_id: int, message: String) -> void:
	"""
	Sends a message from the given player id in the pre-game lobby.
	"""
	
	var current_scene: Node = get_tree().current_scene
	
	if _gamestate == gamestate.PRE_GAME and current_scene.get_name() == "Lobby":
		if player_id in _players:
			var player: Node = _players[player_id]
			var chat_box = current_scene.get_node("Content/CenterBackground/Center/ChatContainer/ChatBox")
			var chat_message = preload("res://src/main/menus/lobby/chat/ChatMessage.tscn").instance()
			
			chat_message.get_node("Player").set_text(player.get_username() + ": ")
			chat_message.get_node("Message").set_text(message)
			
			chat_box.add_child(chat_message)
			
			if chat_box.get_child_count() > 16:
				chat_box.remove_child(chat_box.get_child(0))


func request_to_start_game() -> void:
	"""
	Sends a request to the server to start the game.
	"""
	
	rpc_id(1, "start_game")


remote func start_game() -> void:
	"""
	Starts the game.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	for player_id in _players:
		var lobby_player: Node = _players[player_id]
		var game_player: Node = preload("res://src/main/game/player/Player.tscn").instance()
		
		game_player.set_name(lobby_player.get_name())
		game_player.set_username(lobby_player.get_username())
		game_player.set_host(lobby_player.is_host())
		game_player._network_id = player_id
		
		if player_id == root_id:
			game_player.set_root_player(true)
		
		_players[player_id] = game_player
	
	_gamestate = gamestate.IN_GAME
	
	get_tree().change_scene(_GAME_SCENE_PATH)


func send_player_movement(x: float, y: float) -> void:
	"""
	Send player movement to the server.
	"""
	
	rpc_unreliable_id(1, "player_movement", x, y)


remote func peer_movement(peer_id: int, x: float, y: float) -> void:
	"""
	Changes the position of a peer player based on their movement.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.position.x = x
			player.position.y = y


func send_change_facing_direction(facing_direction: int) -> void:
	"""
	Sends a facing direction change to the server.
	"""
	
	rpc_unreliable_id(1, "change_facing_direction", facing_direction)


remote func change_facing_direction(peer_id: int, facing_direction: int) -> void:
	"""
	Changes the facing direction of the given player.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.set_facing_direction(facing_direction)


func send_change_gun_position(gun_position: int) -> void:
	"""
	Sends a gun change position request to the server.
	"""
	
	rpc_unreliable_id(1, "change_gun_position", gun_position)


remote func change_gun_position(peer_id: int, gun_position: int) -> void:
	"""
	Changes the gun position of the given player.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			var gun: Node = player.get_node("Gun")
			
			if gun_position == 1:
				gun.scale.x = 1
				gun.position.x = 40
			else:
				gun.scale.x = -1
				gun.position.x = -40


func send_change_player_state(player_state: int) -> void:
	"""
	Sends a request to the server to change this player's player state.
	"""
	
	rpc_unreliable_id(1, "change_player_state", player_state)


remote func change_player_state(peer_id: int, player_state: int) -> void:
	"""
	Changes the player state of the given peer.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.set_player_state(player_state)


func send_change_x_input(x_input: float) -> void:
	"""
	Sends a request to the server to change this player's x input.
	"""
	
	rpc_unreliable_id(1, "change_x_input", x_input)


remote func change_x_input(peer_id: int, x_input: float) -> void:
	"""
	Changes the x input of the given peer.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.set_x_input(x_input)


func send_bullet_shot(x_dir: float, y_dir: float) -> void:
	"""
	Sends a request to the server to shoot a bullet.
	"""
	
	rpc_unreliable_id(1, "bullet_shot", x_dir, y_dir)


remote func bullet_shot(peer_id: int, x_dir: float, y_dir: float) -> void:
	"""
	Shoots a bullet from the peer.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.shoot_bullet(Vector2(x_dir, y_dir))


func send_change_health(player_id: int, health: float, shield: float) -> void:
	"""
	Sends a request to the server to change the shield and health.
	"""
	
	rpc_unreliable_id(1, "change_health", player_id, health, shield)


remote func change_health(peer_id: int, health: float, shield: float) -> void:
	"""
	Changes the health and shield of the given peer.
	"""
	
	if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player._health = health
			player._shield = shield


func send_change_kills(player_id: int, kills: int) -> void:
	"""
	Sends a request to the server to change the kills of the player.
	"""
	
	rpc_unreliable_id(1, "change_kills", player_id, kills)


remote func change_kills(peer_id: int, kills: int) -> void:
	"""
	Changes the kills of the given peer.
	"""
	
	if peer_id in _players:
		var player: Node = _players[peer_id]
		
		player._kills = kills


func send_change_deaths(player_id: int, deaths: int) -> void:
	"""
	Sends a request to the server to change the deaths of the player.
	"""
	
	rpc_unreliable_id(1, "change_deaths", player_id, deaths)


remote func change_deaths(peer_id: int, deaths: int) -> void:
	"""
	Changes the kills of the given peer.
	"""
	
	if peer_id in _players:
		var player: Node = _players[peer_id]
		
		player._deaths = deaths


func send_dash_particles() -> void:
	"""
	Sends dash particles request to the server.
	"""
	
	rpc_unreliable_id(1, "dash_particles")


remote func dash_particles(peer_id: int) -> void:
	"""
	Activates dash particles for the given peer.
	"""
	
	var root_id: int = get_tree().get_network_unique_id()
	
	if root_id != peer_id:
		if peer_id in _players:
			var player: Node = _players[peer_id]
			
			player.get_node("DashParticles").emitting = true
