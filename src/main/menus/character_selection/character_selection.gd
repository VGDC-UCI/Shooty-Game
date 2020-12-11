extends Control


func _ready() -> void:
	_load_player()


func _load_player() -> void:
	var player_card: Control = load('res://src/main/menus/lobby/PlayerCard.tscn').instance()

	$VBoxContainer/PlayerList.add_child(player_card)
	player_card.set_lobby_player(server.get_root_player())
	player_card.disable_name_editing()
	player_card.hide_remove_button()


func _on_ready_button_pressed() -> void:
	_change_to_lobby()


func _change_to_lobby() -> void:
	_send_changes_to_server()
	get_tree().change_scene(server._LOBBY_SCENE_PATH)


func _send_changes_to_server() -> void:
	server.send_class_change(server.get_root_player().get_class_id())
	server.send_change_team(server.get_root_player().get_team())