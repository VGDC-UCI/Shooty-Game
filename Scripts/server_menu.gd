extends Control


func _ready() -> void:
	"""
	Called when the node enters the scene tree for the first time.
	Makes connections between signals and sets default text for the
	username and the ip address.
	"""
	
	# Connects the given signals to the given functions.
	gamestate.connect( "connection_succeeded", self, "_on_connection_succeeded" )
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
	
	if len( player_name ) == 0:
		get_node( "LoginScreen/ErrorText" ).text = "Please enter a name!"
		return
	
	var ip: String = get_node( "LoginScreen/IPTextbox" ).text
	
	if not ip.is_valid_ip_address():
		get_node( "LoginScreen/ErrorText" ).text = "Invalid IP Address!"
		return

	get_node( "LoginScreen/ErrorText" ).text = "Connecting to host..."

	gamestate.join_game( ip, player_name )


func _on_host_button_pressed() -> void:
	"""
	Called when the HostButton is pressed. Attemps to host a server
	for the game.
	"""
	
	var player_name: String = get_node( "Login/NameTextbox" ).text
	
	if len( player_name ) == 0:
		get_node( "Login/ErrorText" ).text = "Please enter a name."
		return

	get_node( "Login/ErrorText" ).text = "Setting up server..."

	gamestate.host_game( player_name )
	refresh_player_list()


func _on_start_button_pressed() -> void:
	"""
	Called when the StartButton is pressed. Attempts to start the game.
	"""
	
	gamestate.begin_game()


func _on_connection_succeeded() -> void:
	"""
	Called from the connection_succeeded signal. Shows the pregame screen
	to the user.
	"""
	
	get_node( "LoginScreen" ).hide()
	get_node( "PregameScreen" ).show()


func _on_connection_failed() -> void:
	"""
	Called from the connection_failed signal. Notifies the user that
	the connection failed.
	"""
	
	get_node( "Login/ErrorText" ).text = "Failed to connect to host."


func _on_game_error( error_text: String ) -> void:
	"""
	Called from the game_ended signal. Shows an error popup to the user
	with the error.
	"""
	
	get_node( "ErrorDialog" ).dialog_text = error_text
	get_node( "ErrorDialog" ).show()


func _on_game_ended() -> void:
	"""
	Called from the game_ended signal. Brings the user back to
	the LoginScreen Node.
	"""
	
	get_node( "PregameScreen" ).hide()
	get_node( "Login" ).show()


func refresh_player_list() -> void:
	"""
	Called from the player_list_changed signal. Refreshes the list of
	players in the PregameScreen.
	"""
	
	var player_list: Array = gamestate.get_player_list() # Array<String>
	player_list.sort()
	
	get_node( "PregameScreen/PlayerList" ).clear()
	
	get_node( "PregameScreen/PlayerList" ).add_item( gamestate.get_player_name() + " (You)" )
	
	for player_name in player_list:
		get_node( "PregameScreen/PlayerList" ).add_item( player_name )

	get_node( "PregameScreen/StartGame" ).disabled = not get_tree().is_network_server()

