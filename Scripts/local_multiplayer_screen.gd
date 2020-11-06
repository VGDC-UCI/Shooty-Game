extends Control


# References
onready var player_list: ItemList = $HBoxContainer/Players/MarginContainer/VBoxContainer/PlayerList
onready var player_options: Control = $HBoxContainer/PlayerOptions
var player_config: GDScript = load('res://Scripts/player_config.gd')
# States
var player_configs: Array = []


func _ready() -> void:
	add_player()
	

func add_player() -> void:
	var index: int = player_list.get_item_count()
	var name: String = 'Player ' + str(index + 1)

	player_list.add_item(name)

	var config: Resource = player_config.new()
	config.initialize(name)
	player_configs.append(config)

	display_player_options_for(index)
	

func display_player_options_for(index: int) -> void:
	var config: Resource = player_configs[index]
	player_options.display_for(config)
		

