"""
Controls the current Game State of the game. Is a Singleton.
Always has to be in sync with the rest of the players

Author: Srayan Jana
"""

extends Node

# Default game port. Can be any number between 1024 and 49151.
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

# Name for my player.
# var player_name = "The Warrior"
var player_config = {
	"name" : "The Warrior",
	"class_id" : 0,
	"input_id" : 0
}

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_config["name"])


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = {
		"name" : new_player_name,
		"class_id" : 0,
		"input_id" : 0
	}
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


func sync_player_config_for_others(updated_config: Dictionary) -> void: # Syncs the config with the gamestate and others as well
	player_config = updated_config
	for id in players.keys():
		rpc_id(id, "update_player_configs", get_tree().get_network_unique_id(), player_config)


remote func update_player_configs(id: int, updated_config: Dictionary):
	players[id] = updated_config
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_points):
	# Change scene.
	var world = load("res://src/main/world/World.tscn").instance()

	get_tree().get_root().get_node("ServerMenu").hide()

	# var player_scene = load("res://src/main/game/player/Player.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position

		var player: Player
		if p_id in players:
			player = Classes.get_class_scene(players[p_id]["class_id"]).instance()
		else:
			player = Classes.get_class_scene(player_config["class_id"]).instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position = spawn_pos
		player.spawn_point = spawn_pos
		player.set_network_master(p_id) #set unique id as master.

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_config["name"])
			player.get_node("PlayerController").control_scheme = ControlSchemes.get_scheme_data(player_config["input_id"])
			player.get_node("PlayerController").using_controller = ControlSchemes.get_scheme_type(player_config["input_id"]) == ControlSchemes.types.CONTROLLER
			player.get_node("PlayerController").training_mode = ControlSchemes.get_scheme_type(player_config["input_id"]) == ControlSchemes.types.DUMMY
			player.get_node("Camera2D").current = false
			player.local_camera = false
			#player.get_node("Camera2D").visible = true
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id]["name"])
			player.get_node("PlayerController").control_scheme = ControlSchemes.get_scheme_data(2)
			player.get_node("PlayerController").using_controller = false
			player.get_node("PlayerController").training_mode = true
			player.get_node("Camera2D").current = false
			player.local_camera = false
			#player.get_node("Camera2D").visible = false

		world.get_node("Players").add_child(player)

	get_tree().get_root().add_child(world)
	world.get_node("Camera2D").current = true

	# Set up score.
	#world.get_node("Score").add_player(get_tree().get_network_unique_id(), player_name)
	#for pn in players:
	#	world.get_node("Score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_config["name"] = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)


func join_game(ip, new_player_name):
	player_config["name"] = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)


func get_player_list():
	return players.values()


func get_player_config() -> Dictionary:
	return player_config


func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
