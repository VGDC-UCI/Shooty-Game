"""
Adds functionality for keyboard support in the menu
and handles button input for the exit button.

Author: Kang Rui Yu & Jacob Singleton
"""


extends Control


func _ready() -> void:
	"""
	Called when the title screen is loaded. Grabs focus of
	the first button to allow keyboard support.
	"""
	
	$Menu/Buttons/LocalGame.grab_focus()


func _on_exit_button_pressed() -> void:
	"""
	Called when the exit button is pressed. Closes the game.
	"""
	
	get_tree().quit()
