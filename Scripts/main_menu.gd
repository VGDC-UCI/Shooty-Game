extends Control


# References
const SERVER_MENU_PATH: String = 'res://Scenes/ServerMenu.tscn'


func switch_to_localmulti() -> void:
	pass
	

func switch_to_multi() -> void:
	get_tree().change_scene(SERVER_MENU_PATH)
	

func switch_to_training() -> void:
	pass