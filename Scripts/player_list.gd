extends Control

# References
onready var list: ItemList = $MarginContainer/VBoxContainer/List
var player_config: GDScript = load('res://Scripts/player_config.gd')
# States
var player_configs: Array = []
# Signals
signal selected(config)


func add_player() -> void:
	var config: Resource = player_config.new()
	config.initialize("Player " + str(list.get_item_count() + 1))
	player_configs.append(config)
	update_list()
	

func update_list() -> void: # Update the list to match the player configs
	list.clear() # Not efficient to clear the list every time, but impact should be insignificant
	for config in player_configs:
		list.add_item(config.name)
		

func selected_player(index: int) -> void: # Redirects ItemList signal to a signal that can be accessed by the root
	emit_signal("selected", player_configs[index])
