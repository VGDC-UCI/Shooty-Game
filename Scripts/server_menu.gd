# Handles the functionality of the ServerMenu.


extends Control


func _ready() -> void:
	"""
	Called when the node enters the scene tree for the first time.
	Makes connections between signals and sets default text for the
	username and the ip address.
	"""
	
	# Connects the given signals to the given functions.
	gamestate.connect( "connection_succeeded", self, "_display_pregame_screen" )
	gamestate.connect( "connection_failed", self, "_on_connection_failed" )
	
	gamestate.connect( "game_error", self, "_on_game_error" )
	gamestate.connect( "game_ended", self, "_on_game_ended" )
	
	gamestate.connect( "player_list_changed", self, "refresh_player_list" )
	
	if OS.has_environment( "USERNAME" ):
		get_node( "LoginScreen/NameTextbox" ).text = OS.get_environment( "USERNAME" )
	
	# 127.0.0.1 is the address for a local server.
	get_node( "LoginScreen/IPTextbox" ).text = "127.0.0.1"


func _on_join_button_pressed() -> void:
	"""
	Called when the JoinButton is pressed. Attempts to join a remote
	host.
	"""
	
	var player_name: String = get_node( "LoginScreen/NameTextbox" ).text
	
	if player_name == null or len( player_name ) == 0:
		get_node( "LoginScreen/ErrorText" ).text = "Please enter a name!"
		return
	
	var ip: String = get_node( "LoginScreen/IPTextbox" ).text
	
	if not ip.is_valid_ip_address():
		get_node( "LoginScreen/ErrorText" ).text = "Invalid IP Address!"
		return

	get_node( "LoginScreen/ErrorText" ).text = "Connecting to host..."
	
	get_node( "LoginScreen/JoinButton" ).disabled = true
	get_node( "LoginScreen/HostButton" ).disabled = true

	gamestate.join_game( ip, player_name )


func _on_host_button_pressed() -> void:
	"""
	Called when the HostButton is pressed. Attemps to host a server
	for the game.
	"""
	
	var player_name: String = get_node( "LoginScreen/NameTextbox" ).text
	
	if player_name == null or len( player_name ) == 0:
		get_node( "LoginScreen/ErrorText" ).text = "Please enter a name."
		return

	gamestate.host_game( player_name )
	
	_display_pregame_screen()


func _on_start_button_pressed() -> void:
	"""
	Called when the StartButton is pressed. Attempts to start the game.
	"""
	
	gamestate.begin_game()
	

func _display_login_screen() -> void:
	"""
	Displays the LoginScreen to the user. Re-activates all disabled buttons.
	"""
	
	get_node( "PregameScreen" ).hide()
	get_node( "LoginScreen" ).show()
	
	get_node( "LoginScreen/HostButton" ).disabled = false
	get_node( "LoginScreen/JoinButton" ).disabled = false


func _display_pregame_screen() -> void:
	"""
	Called from the connection_succeeded signal. Displays the 
	PregameScreen to the user.
	"""
	
	get_node( "LoginScreen/HostButton" ).disabled = true
	get_node( "LoginScreen/JoinButton" ).disabled = true
	get_node( "LoginScreen/ErrorText" ).text = ""
	get_node( "LoginScreen" ).hide()
	
	get_node( "PregameScreen" ).show()
	get_node( "PregameScreen/PlayerList" ).add_item( gamestate.get_player_name() + " (You)" )
	
	# Condition is true if the user is hosting the server.
	if get_tree().is_network_server():
		get_node( "PregameScreen/StartButton" ).show()
		get_node( "PregameScreen/WaitingText" ).hide()
	else:
		get_node( "PregameScreen/StartButton" ).hide()
		get_node( "PregameScreen/WaitingText" ).show()


func _on_connection_failed() -> void:
	"""
	Called from the connection_failed signal if the user failed to connect
	to the host. Notifies the user that the connection failed.
	"""
	
	get_node( "LoginScreen/ErrorText" ).text = "Failed to connect to the host."


func _on_game_error( error_text: String ) -> void:
	"""
	Called from the game_ended signal. Shows an error popup to the user
	with the error.
	"""
	
	_display_login_screen()
	
	get_node( "ErrorDialog" ).dialog_text = error_text
	get_node( "ErrorDialog" ).show()


func _on_game_ended() -> void:
	"""
	Called from the game_ended signal. Brings the user back to
	the LoginScreen Node.
	"""
	
	_display_login_screen()


func refresh_player_list() -> void:
	"""
	Called from the player_list_changed signal. Refreshes the list of
	players in the PregameScreen.
	"""
	
	var player_list: Array = gamestate.get_player_list() # Array<String>
	player_list.sort()
	
	get_node( "PregameScreen/PlayerList" ).clear()
	
	get_node( "PregameScreen/PlayerList" ).add_item( gamestate.get_player_name() + " (You)" )
	
	# Every player name besides the player name for this user is in this list.
	for player_name in player_list:
		get_node( "PregameScreen/PlayerList" ).add_item( player_name )

