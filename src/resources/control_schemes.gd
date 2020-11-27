"""
A file that stores all the key mappings for the game

Author: Kang Rui Yu
"""

extends Node

enum types {KEYBOARD, CONTROLLER, DUMMY}

var data: Dictionary = {
	0 : {
		"name" : "Keyboard",
		"type" : types.KEYBOARD,
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
		"type" : types.CONTROLLER,
		"mappings" : {
			"right" : "controller_right",
			"left" : "controller_left",
			"jump" : "controller_jump",
			"dash" : "controller_dash",
			"shoot" : "controller_shoot",
			"shield" : "controller_shield"
		}
	},
	2 : {
		"name" : "Training Dummy",
		"type" : types.DUMMY,
		"mappings" : {
			"right" : "",
			"left" : "",
			"jump" : "",
			"dash" : "",
			"shoot" : "",
			"shield" : ""
		}
	}
}


func get_scheme_names() -> PoolStringArray: # Returns the names of all possible control schemes
	var names: PoolStringArray = PoolStringArray()

	for id in data.keys():
		names.append(data[id]["name"])

	return names


func get_scheme_data(scheme_id: int) -> Dictionary:
	return data[scheme_id]["mappings"]


func get_scheme_type(scheme_id: int) -> int:
	return data[scheme_id]["type"]

