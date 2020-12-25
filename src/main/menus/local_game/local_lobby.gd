"""
Handles the lobby for a local game (Adding, removing, starting game, etc).

Author: Kang Rui Yu & Jacob Singleton
"""

extends Control


# References
var lobby_player_scene: PackedScene = load("res://src/main/menus/lobby/player/LobbyPlayer.tscn")
var main_menu_scene_path: String = "res://src/main/menus/title/Title.tscn"
# States
var _players: Array = []


func _ready() -> void:
	"""
	Initializes the lobby with one player in it.
	"""
	_add_new_player()


func _on_add_player_button_pressed() -> void:
	"""
	Called when the add player button is pressed in the lobby.
	"""
	_add_new_player()


func _on_ready_button_pressed() -> void:
	"""
	Called when the ready button is pressed in the lobby.
	"""
	_begin_game()


func _on_leave_button_pressed() -> void:
	"""
	Called when the leave button is pressed in the lobby.
	"""
	_exit_back_to_main_menu()


func _add_new_player() -> void:
	"""
	Adds a new player to the lobby.
	"""
	var lobby_player: Node = lobby_player_scene.instance()

	# Sets the username of the new player to increments of "Player 1", "Player 2", etc
	var username: String = 'Player ' + str($VBoxContainer/PlayerList.get_child_count() + 1)
	lobby_player.set_username(username)

	_players.append(lobby_player)

	# Creates a new player card for the newly created player data and displays it
	var player_card: Control = load('res://src/main/menus/lobby/PlayerCard.tscn').instance()
	$VBoxContainer/PlayerList.add_child(player_card)
	player_card.set_lobby_player(lobby_player)
	player_card.connect('deleted', self, '_remove_player') # Attach a callback to the remove player function when the card is deleted


func _remove_player(lobby_player: Control) -> void:
	"""
	Removes the player from the lobb.
	"""
	_players.erase(lobby_player)


func _begin_game() -> void:
	"""
	Starts the game.
	"""
	# Creates actual player nodes for each player in the lobby
	for player_id in _players.size():
		var lobby_player: Node = _players[player_id]
		var game_player: Node = characters.get_character_scene(_players[player_id].get_class_id()).instance()

		game_player.set_name(lobby_player.get_name())
		game_player.set_username(lobby_player.get_username())
		game_player.set_controls_id(lobby_player.get_input_id())
		game_player.set_team(lobby_player.get_team())
		game_player.set_root_player(true)
		game_player.set_local(true)

		lobby_player.queue_free() # Delete lobby player when not needed to avoid memory leaks
		_players[player_id] = game_player

		server._players[player_id] = _players[player_id] # Accessing private is not preferred, but don't have much time

	# Creates the world (level) and switches to it
	var world: Node2D = load(server._GAME_SCENE_PATH).instance()

	world.get_node('Camera').current = true # Turn on the multi-target camera (only used in local)
	world.get_node('Camera')._targets = _players
	world.get_node('Camera').set_process(true)

	var packed_world: PackedScene = PackedScene.new() # Packs the world before switching into it
	packed_world.pack(world)

	get_tree().change_scene_to(packed_world)


func _exit_back_to_main_menu() -> void:
	"""
	Exits the lobby and switches back to the main menu.
	"""
	for player in _players: # Must delete lobby players before exiting to avoid memory leaks
		player.queue_free()

	get_tree().change_scene(main_menu_scene_path)

