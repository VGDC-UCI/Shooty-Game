"""
Changes the default username of the player to their OS
username.

Author: Jacob Singleton, Kang Rui Yu
"""


extends Control


var lobby_player_scene: PackedScene = load('res://src/main/menus/lobby/player/LobbyPlayer.tscn')

export var _players: Array = []


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


func set_players(players: Array) -> void:
	_players = players


func _on_start_button_pressed() -> void:
	"""
	Called when the start button is pressed.
	"""
	for player_id in _players.size():
		var lobby_player: Node = _players[player_id]
		var game_player: Node = characters.get_character_scene(_players[player_id].get_class_id()).instance()

		game_player.set_name(lobby_player.get_name())
		game_player.set_username(lobby_player.get_username())
		game_player.set_root_player(true)
		game_player.set_local(true)
		game_player._controls_id = _players[player_id].get_input_id()
		game_player.set_team(_players[player_id].get_team())

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
