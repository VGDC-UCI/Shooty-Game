"""
Handles broad menu button functionality on what happens when you
hover over it.

Author: Jacob Singleton
"""


extends Button


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
