"""
Changes the background shadow color of the title text
when it is clicked.

Author: Jacob Singleton
"""


extends Button


func _on_button_pressed() -> void:
	"""
	Called when the title is pressed.
	Changes the background shadow color of the title text.
	"""
	
	$TitleText.add_color_override("font_color_shadow",
								  Color(rand_range(0, 1),
										rand_range(0, 1),
										rand_range(0, 1)))
