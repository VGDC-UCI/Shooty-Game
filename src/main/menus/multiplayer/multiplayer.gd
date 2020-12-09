"""
Changes the default username of the player to their OS
username.

Author: Jacob Singleton
"""


extends Control


func _ready() -> void:
	"""
	Called when the scene is loaded. 
	Grabs focus of the first button to allow keyboard support.
	"""
	
	if server.disconnect_reason != null:
		$Content/Center/ErrorText.set_text(server.disconnect_reason)
	
	for button in $Content/Center/Buttons.get_children():
		button.disabled = false
	
	$Content/Center/Buttons/MainServer.grab_focus()


func _on_main_server_button_pressed() -> void:
	"""
	Called when the main server button is pressed.
	Attempts to connect to the main dedicated server.
	Fails if the player hasn't inputted a username.
	"""
	
	_connect_to_server(server.MAIN_HOST, server.MAIN_PORT)


func _on_direct_connect_button_pressed() -> void:
	"""
	Called when the direct connect button is pressed.
	Unhides the host address textbox if it is hidden.
	Otherwise, it tries to connect to the inputted host.
	"""
	
	if not $Content/Center/HostTextbox.is_visible():
		$Content/Center/HostTextbox.set_visible(true)
	else:
		var error_text: Label = $Content/Center/ErrorText
		var host: String = $Content/Center/HostTextbox.text
		
		if len(host) == 0:
			error_text.text = "Enter a host address."
		else:
			var port: int = 10567
			
			if ':' in host:
				var split_host = host.split(':')
				
				host = split_host[0]
				port = int(split_host[1])
			
			_connect_to_server(host, port)


func _connect_to_server(host: String, port: int) -> void:
	"""
	Attempts to connect the player to the given server.
	"""
	
	var username: String = $Content/Center/UsernameTextbox.text
	var error_text: Label = $Content/Center/ErrorText
	
	if len(username) == 0:
		error_text.text = "Please input a username!"
	else:
		error_text.text = "Connecting to server..."
		
		for button in $Content/Center/Buttons.get_children():
			button.disabled = true
		
		var player: Node = preload("res://src/main/menus/lobby/player/LobbyPlayer.tscn").instance()
		
		player.set_username(username)
		player.set_text(username + " (You)")
		
		if not server.connect_to_server(host, port, player):
			error_text.text = "Unable to connect to the server."
