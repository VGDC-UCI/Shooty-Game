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
	Also loads in all players into the lobby.
	"""
	
	randomize()
	
	$Content/Buttons/StartButton.grab_focus()
	
	for player in server.get_players():
		if player.get_team() == 1:
			$Content/CenterBackground/Center/Players/Team1List.add_child(player)
		else:
			$Content/CenterBackground/Center/Players/Team2List.add_child(player)
	
	var character_select: Node = $Content/CenterBackground/Center/Settings/Character/Select
	
	for character_name in characters.get_character_names():
		character_select.add_item(character_name)
	
	$Content/CenterBackground/Center/Settings/Portrait.texture = characters.get_character_portrait(server.get_root_player().get_class_id())
	
	var team_select: Node = $Content/CenterBackground/Center/Settings/Team/Select
	
	team_select.add_item("Team 1")
	team_select.add_item("Team 2")
	
	team_select.select(server.get_root_player().get_team() - 1)
	
	if server.get_root_player().is_host():
		$Content/Buttons/StartButton.set_visible(true)


func _on_start_button_pressed() -> void:
	"""
	Called when the start button is pressed.
	"""
	
	if server.get_root_player().is_host():
		server.request_to_start_game()


func _on_leave_button_pressed() -> void:
	"""
	Called when the leave button is pressed.
	Leaves the lobby.
	"""
	
	server.disconnect_reason = "You have left the server."
	
	server.disconnect_from_server()


func _on_message_box_text_entered(new_text: String):
	"""
	Called when entering text into the message box for chat.
	Sends the chat message.
	"""
	
	if len(new_text.strip_edges()) > 0:
		var message_box = $Content/CenterBackground/Center/ChatContainer/MessageBox
		
		message_box.set_text("")
		
		server.send_chat_message(new_text.to_lower())


func _on_character_change(index):
	"""
	Called when the player changes what character they are playing.
	"""
	
	server.send_class_change(index)


func _on_team_change(index):
	"""
	Called when the player changes what team they are on.
	"""
	
	server.send_change_team(index + 1)
