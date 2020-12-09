"""
A file that store the string paths for each class

Author: Kang Rui Yu
"""

extends Node

var data: Dictionary = {
	0 : {
		"name" : "Molly Rosenthal",
		"portrait" : "res://src/main/game/player/textures/molly_portrait.png",
		"scene_path" : "res://src/main/game/player/classes/Molly.tscn"
	},
	1 : {
		"name" : "Sally",
		"portrait" : "res://src/main/game/player/textures/sally_portrait.png",
		"scene_path" : "res://src/main/game/player/classes/Sally.tscn"
	}
}


func get_class_names() -> PoolStringArray: # Returns the name of all class names
	var names: PoolStringArray = PoolStringArray()

	for id in data.keys():
		names.append(data[id]["name"])

	return names


func get_class_portrait(class_id: int) -> Resource: # Returns the portrait for the given class
	return load(data[class_id]["portrait"])


func get_class_scene(class_id: int) -> Resource: # Returns the packed scene of the given class id
	return load(data[class_id]["scene_path"])
