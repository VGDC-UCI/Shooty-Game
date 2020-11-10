"""
The main menu UI. Manages switching scenes to other menus.

Author: Kang Rui Yu
"""
extends Control


# References
const SERVER_MENU_PATH: String = 'res://Scenes/ServerMenu.tscn'
const LOCAL_MULTI_PATH: String = 'res://Scenes/LocalMultiplayerScreen.tscn'


func switch_to_localmulti() -> void:
	get_tree().change_scene(LOCAL_MULTI_PATH)
	

func switch_to_multi() -> void:
	get_tree().change_scene(SERVER_MENU_PATH)
	

func switch_to_training() -> void:
	pass