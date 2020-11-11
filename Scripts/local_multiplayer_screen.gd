"""
The main script for the local multiplayer screen. Controls starting the game
and creating a local server.

Author: Kang Rui Yu
"""

extends Control

# References
onready var player_list: Control = $HBoxContainer/PlayerList
var player_scene: PackedScene = load("res://Scenes/Player.tscn")
var level_scene: PackedScene = load("res://Scenes/World.tscn")
# Constants
const DEFAULT_PORT = 10567
const MAX_PEERS = 12


func start_game() -> void:
	var level: Node2D = level_scene.instance()

	var spawn_points: Array = level.get_node("SpawnPoints").get_children()
	var current_spawn_point: int = 0

	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

	for config in player_list.player_configs:
		var player: Player = player_scene.instance()
		level.get_node('Players').add_child(player)

		player.set_player_name(config.name)

		player.position = spawn_points[current_spawn_point].position
		player.spawn_point = player.position

		current_spawn_point += 1
		if current_spawn_point >= spawn_points.size():
			current_spawn_point = 0

	get_tree().get_root().add_child(level)
	queue_free()
