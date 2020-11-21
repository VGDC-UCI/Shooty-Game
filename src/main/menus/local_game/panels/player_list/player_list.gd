"""
A UI that displays a list a players and stores a corresponding list of
player configurations. Also provides the ability to add or remove players.

Author: Kang Rui Yu
"""

extends Control

# References
onready var list: ItemList = $MarginContainer/VBoxContainer/List
var player_config: GDScript = load("res://src/main/menus/local_game/player_config.gd")
# States
var player_configs: Array = []
# Signals
signal selected(config)


func add_player() -> void:
	var config: Resource = player_config.new()
	config.initialize("Player " + str(list.get_item_count() + 1))
	player_configs.append(config)
	update_list()

	list.select(list.get_item_count() - 1) # Select the last player on the list
	emit_signal("selected", config)


func remove_player() -> void: # Will remove the currently selected player
	if player_configs.size() == 0:
		return

	var index: int = list.get_selected_items()[0]
	player_configs.remove(index)
	update_list()

	if index >= 1:
		list.select(index - 1) # Select the player before the removed one
		emit_signal("selected", player_configs[index - 1])


func update_list() -> void: # Update the list to match the player configs
	list.clear() # Not efficient to clear the list every time, but impact should be insignificant
	for config in player_configs:
		list.add_item(config.name)


func selected_player(index: int) -> void: # Redirects ItemList signal to a signal that can be accessed by the root
	emit_signal("selected", player_configs[index])
