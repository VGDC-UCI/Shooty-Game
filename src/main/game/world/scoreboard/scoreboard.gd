"""
UI element that displays the state and score of a list of players.

Author: Kang Rui Yu
"""


extends HBoxContainer


"References"
var player_score_scene: PackedScene = load('res://src/main/game/world/scoreboard/PlayerScore.tscn')


func initialize_board(players: Array) -> void:
	for player in players:
		_add_player(player)


func _add_player(player: Player) -> void:
	var player_score := player_score_scene.instance()
	
	player_score.set_name(player.get_name())
	add_child(player_score)
	player_score.track_player(player)
