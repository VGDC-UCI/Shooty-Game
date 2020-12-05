"""
The main script for the lobby screen. Controls starting the game
and creating a local server.

Author: Kang Rui Yu
"""

extends Control

# References
onready var player_list: Control = $MarginContainer/HBoxContainer
var player_card_scene: PackedScene = load("res://src/main/menus/lobby/PlayerCard.tscn")
# Signal
signal configs_changed # Emitted when one of the configs changed


func add_new_player(name: String = "@Player", deletable: bool = true, editable: bool = true) -> void:
	var config = {"name" : name, "class_id" : 0, "input_id" : 0}

	if name == "@Player":
		config["name"] = "Player " + str(player_list.get_child_count() + 1)

	add_existing_player(config, deletable, editable)


func add_existing_player(config: Dictionary, deletable: bool = true, editable: bool = true) -> void:
	var player_card: Control = player_card_scene.instance()
	player_list.add_child(player_card)

	player_card.connect("changed", self, "emit_configs_changed")

	player_card.set_config(config)

	if not deletable:
		player_card.hide_remove_button()

	player_card.toggle_editing(editable)


func remove_player(player_card: Control) -> void:
	player_list.remove_child(player_card)
	player_card.queue_free()


func clear() -> void:
	for player_card in player_list.get_children():
		player_card.queue_free()


func get_player_configs() -> Array:
	var configs: Array = []
	for player_card in player_list.get_children():
		configs.append(player_card.get_config())
	return configs


func set_player_configs(configs: Dictionary, deletable: bool = true) -> void: # Syncs configs
	configs.clear()
	clear()

	for config in configs:
		add_existing_player(config, deletable)


func emit_configs_changed() -> void:
	emit_signal("configs_changed")