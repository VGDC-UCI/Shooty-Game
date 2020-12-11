extends Control


var lobby_player_scene: PackedScene = load('res://src/main/menus/lobby/player/LobbyPlayer.tscn')

var _players: Array = []


func _ready() -> void:
	_add_new_player()


func get_players() -> Array:
	return _players


func _on_add_player_button_pressed() -> void:
	_add_new_player()


func _add_new_player():
	var lobby_player: Node = lobby_player_scene.instance()
	var username: String = 'Player ' + str($VBoxContainer/PlayerList.get_child_count() + 1)

	lobby_player.set_username(username)
	lobby_player.text = username

	_players.append(lobby_player)

	var player_card: Control = load('res://src/main/menus/lobby/PlayerCard.tscn').instance()
	$VBoxContainer/PlayerList.add_child(player_card)
	player_card.set_lobby_player(lobby_player)


func _on_ready_button_pressed() -> void:
	_change_to_lobby()


func _change_to_lobby() -> void:
	var local_lobby: Node = load('res://src/main/menus/local game/LocalGame.tscn').instance()
	local_lobby.set_players(get_players())
	var packed_local_lobby: PackedScene = PackedScene.new()
	packed_local_lobby.pack(local_lobby)
	get_tree().change_scene_to(packed_local_lobby)
