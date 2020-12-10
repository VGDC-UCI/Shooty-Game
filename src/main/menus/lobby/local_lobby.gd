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
	for player_id in _players:
		var lobby_player: Node = _players[player_id]
		var game_player: Node = preload("res://src/main/game/player/Player.tscn").instance()

		game_player.set_name(lobby_player.get_name())
		game_player.set_username(lobby_player.get_username())
		game_player.set_root_player(true)

		_players[player_id] = game_player

	get_tree().change_scene(server._GAME_SCENE_PATH)



func _on_leave_button_pressed() -> void:
	"""
	Called when the leave button is pressed.
	Leaves the lobby.
	"""

	# server.disconnect_reason = "You have left the server."

	# server.disconnect_from_server()


func _add_new_player():
	"""
	Adds a player to the lobby
	"""
	var lobby_player = lobby_player_scene.instance()
	lobby_player.set_username('Player')
	lobby_player.set_host(true)
	_players.append(lobby_player)
	$Content/CenterBackground/Center/Players/PlayerList.add_child(lobby_player)
