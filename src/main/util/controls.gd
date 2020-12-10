"""
A file that stores all the key mappings for the game

Author: Kang Rui Yu & Jacob Singleton
"""


extends Node


enum ControlScheme {
	KEYBOARD,
	CONTROLLER
}


var _control_data: Dictionary = {
	0 : {
		"name" : "Keyboard",
		"type" : ControlScheme.KEYBOARD,
		"mappings" : {
			"right" : "move_right",
			"left" : "move_left",
			"jump" : "jump_pressed",
			"dash" : "dash",
			"shoot" : "shoot",
			"shield" : "shield"
		},
	},
	1 : {
		"name" : "Controller",
		"type" : ControlScheme.CONTROLLER,
		"mappings" : {
			"right" : "controller_right",
			"left" : "controller_left",
			"jump" : "controller_jump",
			"dash" : "controller_dash",
			"shoot" : "controller_shoot",
			"shield" : "controller_shield"
		}
	}
}


func get_control_names() -> PoolStringArray:
	"""
	Returns all the types of control names.
	"""
	
	var names = []

	for id in _control_data.keys():
		names.append(_control_data[id]["name"])

	return names


func get_control_type(control_id: int) -> int:
	"""
	Returns the control type from the given control id.
	
	:param control_id: The integer id of the controls.
	"""
	
	return _control_data[control_id]["type"]


func get_control_mappings(control_id: int) -> Dictionary:
	"""
	Returns the control mapping data from the given control id.
	
	:param control_id: The integer id of the controls.
	"""
	
	return _control_data[control_id]["mappings"]
