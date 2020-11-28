"""
The local multiplayer screen. Handles starting a local game.

Author: Kang Rui Yu
"""

extends Control

# References
var main_menu_scene: PackedScene = load("res://src/main/menus/title/MainMenu.tscn")
var level_scene: PackedScene = load("res://src/main/world/World.tscn")
onready var lobby: Control = $Lobby
# Constants
const DEFAULT_PORT = 10567
const MAX_PEERS = 12


func _ready() -> void:
	lobby.add_player()


func start_game() -> void:
	var level: Node2D = level_scene.instance()
	level.get_node("Camera2D").current = true

	var spawn_points: Array = level.get_node("SpawnPoints").get_children()
	var current_spawn_point: int = 0

	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

	for config in lobby.get_player_configs():
		var player: Player = Classes.get_class_scene(config.class_id).instance()
		level.get_node('Players').add_child(player)

		player.set_player_name(config.name)
		player.get_node("PlayerController").control_scheme = ControlSchemes.get_scheme_data(config.input_id)
		player.get_node("PlayerController").using_controller = ControlSchemes.get_scheme_type(config.input_id) == ControlSchemes.types.CONTROLLER

		player.get_node("Camera2D").current = false
		player.local_camera = false

		player.position = spawn_points[current_spawn_point].position
		player.spawn_point = player.position

		current_spawn_point += 1
		if current_spawn_point >= spawn_points.size():
			current_spawn_point = 0

	get_tree().get_root().add_child(level)
	queue_free()


func return_to_main_menu() -> void:
	get_tree().change_scene_to(main_menu_scene)
