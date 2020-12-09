"""
Handles broad menu button functionality on what happens when you click
a menu button and hover over it.

Author: Jacob Singleton
"""


extends Button


export(String) var scene_to_load


func _on_generic_button_pressed() -> void:
	"""
	Called when a generic menu button is pressed. 
	Loads the specified scene if it isn't empty.
	"""
	
	if len(scene_to_load) > 0:
		get_tree().change_scene(scene_to_load)


func _on_focus_entered() -> void:
	"""
	Called when the button is being hovered. Shows the
	color rectangle next to the text.
	"""
	
	$ColorRect.show()


func _on_focus_exited() -> void:
	"""
	Called when the button is no longer being hovered. Removes
	the color rectangle next to the text.
	"""
	
	$ColorRect.hide()


func _on_mouse_entered() -> void:
	"""
	Called when the mouse is hovering over the button. Grabs
	the focus of the button.
	"""
	
	self.grab_focus()
