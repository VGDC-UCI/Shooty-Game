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
		$Content/CenterBackground/Center/Players/PlayerList.add_child(player)
	
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
		
		server.rpc_id(1, "send_chat_message", get_tree().get_network_unique_id(), new_text.to_lower())
