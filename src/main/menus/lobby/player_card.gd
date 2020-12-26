"""
A card that displays character portrait and options.

Author: Kang Rui Yu
"""

extends Control

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
signal deleted(lobby_player) # Emitted when the card is deleted


func _ready() -> void:
	"""
	Initializes the player card by loading in all the available control schemes
	and classes.
	"""
	get_available_control_schemes()
	get_available_classes()


func set_lobby_player(lobby_player: Node) -> void:
	"""
	Sets the lobby player the player card is going to track and modify.
	"""
	_lobby_player = lobby_player
	name_field.text = _lobby_player.get_username()
	class_options.selected = _lobby_player.get_class_id()
	input_options.selected = _lobby_player.get_input_id()
	team_options.value = _lobby_player.get_team()
	update_class_portrait()


func get_available_control_schemes() -> void:
	"""
	Retrieves the available control schemes and loads it into the input options.
	"""
	input_options.clear() # Clear any previously saved input options.
	for control_scheme_name in controls.get_control_names():
		input_options.add_item(control_scheme_name)


func get_available_classes() -> void:
	"""
	Retrieves the available classes and loads it into the class options.
	"""
	class_options.clear() # Clear any previously saved class options.
	for class_title in characters.get_character_names():
		class_options.add_item(class_title)


func name_changed(name: String) -> void:
	"""
	Called when the name is modified.
	"""
	_lobby_player.set_username(name)
	_lobby_player.text = name
	emit_signal("changed")


func class_changed(index: int) -> void:
	"""
	Called when the class changes.
	"""
	_lobby_player.set_class_id(index)
	update_class_portrait()
	emit_signal("changed")


func input_changed(index: int) -> void:
	"""
	Called when the input scheme changes.
	"""
	_lobby_player.set_input_id(index)
	emit_signal("changed")


func team_changed(_new_team: int) -> void:
	"""
	Called when the team number changes.
	"""
	_lobby_player.set_team(_new_team)
	emit_signal("changed")


func update_class_portrait() -> void:
	"""
	Updates the displayed portrait image on the player card to the currently selected class.
	"""
	portrait_image.texture = characters.get_character_portrait(class_options.selected)


func disable_name_editing() -> void:
	"""
	Disables editing on the name field of the player card. (Read-only)
	"""
	name_field.editable = false


func hide_remove_button() -> void:
	"""
	Hides the remove button on the player card.
	"""
	remove_button.hide()


func toggle_editing(editable: bool = false) -> void:
	"""
	Disables editing on the player card.
	"""
	name_field.editable = editable
	class_options.disabled = not editable
	input_options.disabled = not editable
	team_options.editable = editable


func delete() -> void:
	"""
	Deletes the player card and emits a signal. Does not delete the lobby player.
	"""
	emit_signal('deleted', _lobby_player)
	queue_free()
