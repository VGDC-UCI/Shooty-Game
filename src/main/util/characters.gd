"""
A file that store the string paths for each class

Author: Kang Rui Yu & Jacob Singleton
"""


extends Node


var _character_data: Dictionary = {
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


func get_character_names() -> PoolStringArray:
	"""
	Returns all the names of the characters.
	"""
	
	var names: PoolStringArray = PoolStringArray()

	for id in _character_data.keys():
		names.append(_character_data[id]["name"])

	return names


func get_character_portrait_path(character_id: int) -> Resource:
	"""
	Returns the character portrait for the given character.
	
	:param character_id: The id of the character.
	"""
	
	return load(_character_data[character_id]["portrait"])


func get_character_scene(character_id: int) -> Resource:
	"""
	Returns the packed scene of the given character.
	
	:param character_id: The id of the character.
	"""
	
	return load(_character_data[character_id]["scene_path"])
