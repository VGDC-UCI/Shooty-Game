extends Control


func _ready() -> void:
	_load_players(server.get_players())


func _load_players(players: Array) -> void:
	for player in players:
		var player_card: Control = load('res://src/main/menus/lobby/PlayerCard.tscn').instance()

		$VBoxContainer/PlayerList.add_child(player_card)
		player_card.set_lobby_player(player)


func _on_ready_button_pressed() -> void:
	_change_to_lobby()


func _change_to_lobby() -> void:
	get_tree().change_scene(server._LOBBY_SCENE_PATH)
