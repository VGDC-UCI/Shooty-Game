"""
Changes the default username of the player to their OS
username.

Author: Jacob Singleton, Kang Rui Yu
"""


extends Control


var lobby_player_scene: PackedScene = load('res://src/main/menus/lobby/player/LobbyPlayer.tscn')

var _players: Array = []


func _ready() -> void:
	"""
	Called when the scene is loaded.
	Grabs focus of the first button to allow keyboard support.
	Also loads in all players into the lobby.
	"""

	$Content/Buttons/StartButton.grab_focus()

	for player in _players:
		$Content/CenterBackground/Center/Players/PlayerList.add_child(player)

	$Content/Buttons/StartButton.set_visible(true)

	_add_new_player()


func _on_start_button_pressed() -> void:
	"""
	Called when the start button is pressed.
	"""
	for player_id in _players.size():
		var lobby_player: Node = _players[player_id]
		var game_player: Node = preload("res://src/main/game/player/Player.tscn").instance()

		game_player.set_name(lobby_player.get_name())
		game_player.set_username(lobby_player.get_username())
		game_player.set_root_player(true)
		game_player.set_local(true)

		_players[player_id] = game_player

		server._players[player_id] = _players[player_id] # Accessing private is not preferred, but don't have much time


	var world: Node2D = load(server._GAME_SCENE_PATH).instance()
	world.get_node('Camera').current = true
	world.get_node('Camera')._targets = _players
	world.get_node('Camera').set_process(true)
	var packed_world: PackedScene = PackedScene.new()
	packed_world.pack(world)

	get_tree().change_scene_to(packed_world)


func _on_leave_button_pressed() -> void:
	"""
	Called when the leave button is pressed.
	Leaves the lobby.
	"""

	# server.disconnect_reason = "You have left the server."

	# server.disconnect_from_server()


func _on_add_player_button_pressed() -> void:
	"""
	Called when the add player button is pressed.
	"""
	_add_new_player()


func _add_new_player():
	"""
	Adds a player to the lobby
	"""
	var lobby_player: Node = lobby_player_scene.instance()
	var player_list: Control = $Content/CenterBackground/Center/Players/PlayerList
	var username: String = 'Player ' + str(player_list.get_child_count() + 1)

	lobby_player.set_username(username)
	lobby_player.text = username

	_players.append(lobby_player)
	player_list.add_child(lobby_player)
