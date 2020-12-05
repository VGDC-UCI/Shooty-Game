"""
A card that displays character portrait and options.

Author: Kang Rui Yu
"""

extends PanelContainer

# References
onready var portrait_image: TextureRect = $MarginContainer/VBoxContainer/PortraitImage
onready var name_field: LineEdit = $MarginContainer/VBoxContainer/Options/NameField
onready var class_options: OptionButton = $MarginContainer/VBoxContainer/Options/ClassOptions
onready var input_options: OptionButton = $MarginContainer/VBoxContainer/Options/InputOptions
onready var remove_button: Button = $MarginContainer/VBoxContainer/Options/RemoveButton
# Signals
signal changed # Emitted when there is a change to any of the fields


func _ready() -> void:
	get_available_control_schemes()
	get_available_classes()


func set_config(given_config: Dictionary) -> void:
	name_field.text = given_config["name"]
	class_options.selected = given_config["class_id"]
	input_options.selected = given_config["input_id"]
	update_class_portrait()


func get_config() -> Dictionary:
	return {
		"name" : name_field.text,
		"class_id" : class_options.selected,
		"input_id" : input_options.selected
	}


func get_available_control_schemes() -> void: # Retrieves the available control schemes and displays it on the option menus
	input_options.clear()
	for control_scheme_name in ControlSchemes.get_scheme_names():
		input_options.add_item(control_scheme_name)


func get_available_classes() -> void: # Retrieves the available classes and displays it on the option menus
	class_options.clear()
	for class_title in Classes.get_class_names():
		class_options.add_item(class_title)


func set_name(given_name: String) -> void:
	name_field.text = given_name


func name_changed(_name: String) -> void:
	emit_signal("changed")


func class_changed(index: int) -> void:
	update_class_portrait()
	emit_signal("changed")


func input_changed(_index: int) -> void:
	emit_signal("changed")


func update_class_portrait() -> void:
	portrait_image.texture = Classes.get_class_portrait(class_options.selected)


func hide_remove_button() -> void:
	remove_button.hide()


func toggle_editing(editable: bool = false) -> void: # Disables editing on the player card
	name_field.editable = editable
	class_options.disabled = not editable
	input_options.disabled = not editable


func delete() -> void:
	queue_free()
