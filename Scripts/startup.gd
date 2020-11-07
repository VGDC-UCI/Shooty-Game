extends Node2D


func _ready() -> void:
	"""
	Called when the game very first starts. Opens the game as a client
	or as a headless server depending on the startup parameters.
	"""
	
	for argument in OS.get_cmdline_args():
		
		if argument.find( "=" ) >= 0:
			
			var split_key_value: PoolStringArray = argument.split( "=" )
			
			if split_key_value[ 0 ] == '--server_mode' and split_key_value[ 1 ] == 'true':
				get_tree().change_scene( "res://Scenes/Server.tscn" )
				return
	
	get_tree().change_scene( "res://Scenes/MainMenu.tscn" )
