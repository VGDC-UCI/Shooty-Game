"""
A card that displays character portrait and options.

Author: Kang Rui Yu
"""

extends PanelContainer

# References
var _lobby_player: Node = null
onready var portrait_image: TextureRect = $MarginContainer/VBoxContainer/PortraitImage
onready var name_field: LineEdit = $MarginContainer/VBoxContainer/Options/NameField
onready var class_options: OptionButton = $MarginContainer/VBoxContainer/Options/ClassOptions
onready var input_options: OptionButton = $MarginContainer/VBoxContainer/Options/InputOptions
onready var team_options: SpinBox = $MarginContainer/VBoxContainer/Options/TeamOptions
onready var remove_button: Button = $MarginContainer/VBoxContainer/Options/RemoveButton
# Signals
signal changed # Emitted when there is a change to any of the fields


func _ready() -> void:
	get_available_control_schemes()
	get_available_classes()


func set_lobby_player(lobby_player: Node) -> void:
	_lobby_player = lobby_player
	name_field.text = _lobby_player.get_username()
	class_options.selected = _lobby_player.get_class_id()
	input_options.selected = _lobby_player.get_input_id()
	team_options.value = _lobby_player.get_team()
	update_class_portrait()


func get_available_control_schemes() -> void: # Retrieves the available control schemes and displays it on the option menus
	input_options.clear()
	for control_scheme_name in controls.get_control_names():
		input_options.add_item(control_scheme_name)


func get_available_classes() -> void: # Retrieves the available classes and displays it on the option menus
	class_options.clear()
	for class_title in characters.get_character_names():
		class_options.add_item(class_title)


func name_changed(name: String) -> void:
	_lobby_player.set_username(name)
	_lobby_player.text = name
	emit_signal("changed")


func class_changed(index: int) -> void:
	_lobby_player.set_class_id(index)
	update_class_portrait()
	emit_signal("changed")


func input_changed(index: int) -> void:
	_lobby_player.set_input_id(index)
	emit_signal("changed")


func team_changed(_new_team: int) -> void:
	_lobby_player.set_team(_new_team)
	emit_signal("changed")


func update_class_portrait() -> void:
	portrait_image.texture = characters.get_character_portrait(class_options.selected)


func hide_remove_button() -> void:
	remove_button.hide()


func toggle_editing(editable: bool = false) -> void: # Disables editing on the player card
	name_field.editable = editable
	class_options.disabled = not editable
	input_options.disabled = not editable
	team_options.editable = editable


func delete() -> void:
	queue_free()
