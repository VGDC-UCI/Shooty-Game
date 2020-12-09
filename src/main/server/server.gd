"""
Script that handles the client's connection to the server.

Author: Jacob Singleton
"""


extends Node


const _MULTIPLAYER_SCENE_PATH: String = "res://src/main/menus/multiplayer/Multiplayer.tscn"
const _LOBBY_SCENE_PATH: String = "res://src/main/game/lobby/Lobby.tscn"
const _GAME_SCENE_PATH: String = ""

const MAIN_HOST: String = "127.0.0.1"
const MAIN_PORT: int    = 10567

var disconnect_reason = null

var _network := NetworkedMultiplayerENet.new()

var _root_player = null
var _players: Dictionary = {}

enum gamestate {
	PRE_GAME,
	IN_GAME,
	POST_GAME
}

var _gamestate: int = gamestate.PRE_GAME


func connect_to_server(host: String,
					   port: int,
					   lobby_player) -> bool:
	"""
	Connects the player to the server given the host and port.
	Returns whether the connection was successful.
	"""
	
	if _network.create_client(host, port) == OK:
		_root_player = lobby_player
		
		get_tree().set_network_peer(_network)
		
		_network.connect("connection_succeeded", self, "_on_connection_succeeded")
		_network.connect("connection_failed", self, "_on_connection_failed")
		_network.connect("server_disconnected", self, "_on_server_disconnect")
	
		print('Connecting to "' + host + ':' + str(port) + '"')
		
		return true
	else:
		print('Unable to connect to "' + host + ':' + str(port) + '"')
		
		return false


func _on_connection_succeeded() -> void:
	"""
	Called when the player successfully connected to the server.
	"""
	
	if _root_player == null:
		print("Error syncing player data to the server.")
		disconnect_reason = "Error syncing your player data to the server."
		
		disconnect_from_server()
	else:
		_root_player.set_name(str(get_tree().get_network_unique_id()))
		_players[get_tree().get_network_unique_id()] = _root_player
		
		rpc("change_username", get_tree().get_network_unique_id(), _root_player.get_username())
		
		print('Connection succeeded.')


func _on_connection_failed() -> void:
	"""
	Called when the player failed to connect to the server.
	"""
	
	_players.erase(0)
	
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
	_root_player = null
	_players = {}
	_gamestate = gamestate.PRE_GAME


func get_players():
	"""
	Returns the list of players connected to the game.
	"""
	
	return _players.values()


func _get_current_scene() -> Node:
	"""
	Returns the current scene that the game is on.
	"""
	
	return get_tree().current_scene


remote func done_configuring() -> void:
	"""
	Called when the player connecting to the server is done being
	configured by the server.
	"""
	
	get_tree().change_scene(_LOBBY_SCENE_PATH)


remote func change_username(player_id: int, username: String) -> void:
	"""
	Changes the username of the given player id.
	"""
	
	if not player_id == get_tree().get_network_unique_id():
		if player_id in _players:
			var player: Node = _players[player_id]
			
			player.set_username(username)
			player.set_text(username + " (You)")


remote func set_host(player_id: int) -> void:
	"""
	Sets the host to the given player id and removes it from everyone else.
	"""
	
	if _gamestate == gamestate.PRE_GAME:
		for id in _players:
			var player: Node = _players[id]
			
			if id != player_id and player.is_host():
				player.set_host(false)
				
				if player_id == get_tree().get_network_unique_id():
					player.set_text(player.get_username() + " (You)")
				else:
					player.set_text(player.get_username())
				
				if _get_current_scene().get_name() == "Lobby":
					var start_button: Node = _get_current_scene().get_node("Content/Buttons/StartButton")
					
					start_button.set_visible(false)
			
			if id == player_id and not player.is_host():
				player.set_host(true)
				
				if player_id == get_tree().get_network_unique_id():
					player.set_text(player.get_username() + " (You) (Host)")
				else:
					player.set_text(player.get_username() + " (Host)")
				
				if _get_current_scene().get_name() == "Lobby":
					var start_button: Node = _get_current_scene().get_node("Content/Buttons/StartButton")
					
					start_button.set_visible(true)


remote func connect_peer(peer_id: int, username: String, host: bool) -> void:
	"""
	RPC Call sent by the server to connect a peer player.
	"""
	
	if peer_id != get_tree().get_network_unique_id():
		var player: Node = preload("res://src/main/menus/lobby/player/LobbyPlayer.tscn").instance()
		
		player.set_name(str(peer_id))
		player.set_username(username)
		
		if host:
			player.set_text(username + " (Host)")
		else:
			player.set_text(username)
		
		if _get_current_scene().get_name() == "Lobby":
			var player_list: Node = _get_current_scene().get_node("Content/CenterBackground/Center/Players/PlayerList")
			
			player_list.add_child(player)
		
		_players[peer_id] = player


remote func disconnect_player(player_id: int) -> void:
	"""
	Disconnects the given player id connection.
	"""
	
	if player_id in _players:
		if _get_current_scene().get_name() == "Lobby":
			var player_list: Node = _get_current_scene().get_node("Content/CenterBackground/Center/Players/PlayerList")
			
			if _player_id_in_player_list(player_id, player_list):
				player_list.remove_child(player_list.get_node(str(player_id)))
		
		_players.erase(player_id)


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
	
	if _gamestate == gamestate.PRE_GAME and _get_current_scene().get_name() == "Lobby":
		if player_id in _players:
			var player: Node = _players[player_id]
			var chat_box = _get_current_scene().get_node("Content/CenterBackground/Center/ChatContainer/ChatBox")
			var chat_message = preload("res://src/main/menus/lobby/chat/ChatMessage.tscn").instance()
			
			chat_message.get_node("Player").set_text(player.get_username() + ": ")
			chat_message.get_node("Message").set_text(message)
			
			chat_box.add_child(chat_message)
			
			if chat_box.get_child_count() > 16:
				chat_box.remove_child(chat_box.get_child(0))
