"""
A card that displays character portrait and options.

Author: Kang Rui Yu
"""

extends PanelContainer

# Properties
var player_config: Resource = null
# References
onready var portrait_image: TextureRect = $MarginContainer/VBoxContainer/PortraitImage
onready var name_field: LineEdit = $MarginContainer/VBoxContainer/Options/NameField
onready var class_options: OptionButton = $MarginContainer/VBoxContainer/Options/ClassOptions
onready var input_options: OptionButton = $MarginContainer/VBoxContainer/Options/InputOptions


func _ready() -> void:
	get_available_control_schemes()
	get_available_classes()


func set_config(given_config: Resource) -> void:
	player_config = given_config
	name_field.text = player_config.name
	class_options.selected = player_config.class_id
	input_options.selected = player_config.input_id


func get_available_control_schemes() -> void: # Retrieves the available control schemes and displays it on the option menus
	input_options.clear()
	for control_scheme_name in ControlSchemes.get_scheme_names():
		input_options.add_item(control_scheme_name)


func get_available_classes() -> void: # Retrieves the available classes and displays it on the option menus
	class_options.clear()
	for class_title in Classes.get_class_names():
		class_options.add_item(class_title)


func update_name(name: String) -> void:
	player_config.name = name


func update_class(index: int) -> void:
	player_config.class_id = index
	portrait_image.texture = Classes.get_class_portrait(index)


func update_input(index: int) -> void:
	player_config.input_id = index


func delete() -> void:
	queue_free()
