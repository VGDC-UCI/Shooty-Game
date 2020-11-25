"""
The main script for the lobby screen. Controls starting the game
and creating a local server.

Author: Kang Rui Yu
"""

extends Control

# References
onready var player_list: Control = $MarginContainer/HBoxContainer
var player_config: GDScript = load("res://src/main/menus/local_game/player_config.gd")
var player_card_scene: PackedScene = load("res://src/main/menus/lobby/PlayerCard.tscn")


func add_player() -> void:
	var config: Resource = player_config.new()
	config.initialize("Player " + str(player_list.get_child_count() + 1))

	var player_card: Control = player_card_scene.instance()
	player_list.add_child(player_card)
	player_card.set_config(config)


func remove_player(player_card: Control) -> void:
	player_list.remove_child(player_card)
	player_card.queue_free()


func get_player_configs() -> Array:
	var configs: Array = []
	for player_card in player_list.get_children():
		configs.append(player_card.player_config)
	return configs
