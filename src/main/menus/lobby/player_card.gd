"""
A card that displays character portrait and options.

Author: Kang Rui Yu
"""

extends PanelContainer

# Properties
var player_config: Resource = null
# References
onready var name_field: LineEdit = $MarginContainer/VBoxContainer/Options/NameField
onready var class_options: OptionButton = $MarginContainer/VBoxContainer/Options/ClassOptions
onready var input_options: OptionButton = $MarginContainer/VBoxContainer/Options/InputOptions


func _ready() -> void:
	get_available_control_schemes()


func set_config(given_config: Resource) -> void:
	player_config = given_config
	name_field.text = player_config.name
	class_options.selected = player_config.class_id
	input_options.selected = player_config.input_id


func get_available_control_schemes() -> void:
	input_options.clear()
	var control_schemes_data: Dictionary = load("res://src/resources/control_schemes.gd").new().data
	for control_scheme_name in control_schemes_data.keys():
		input_options.add_item(control_scheme_name.capitalize())


func update_name(name: String) -> void:
	player_config.name = name


func update_class(index: int) -> void:
	player_config.class_id = index


func update_input(index: int) -> void:
	player_config.input_id = index


func delete() -> void:
	queue_free()
