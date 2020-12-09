"""
Empty Script for Level stuff. May be useful later

Author: Srayan Jana, Kang Rui Yu
"""

extends Node2D

# References
onready var players_node: Node2D = $Players
onready var camera: Camera2D = $Camera
onready var score_board: Control = $CanvasLayer/ScoreBoard


func _ready() -> void:
	"""
	Called when the world is first loaded, loads in all the
	players and sets up the world.
	"""
	
	var players = server.get_players()
	
	for player in players:
		var player_id = int(player.get_name())
		var spawn_point: Vector2 = _get_random_spawn_point()
		
		player.position = spawn_point
		
		$Players.add_child(player)
	
	camera.targets = players_node.get_children()
	score_board.initialize_board(players_node.get_children())


func _get_random_spawn_point() -> Vector2:
	"""
	Returns a random spawn point.
	"""
	
	var spawn_points = $SpawnPoints
	
	# Picks a random number between 0 and the size of the spawn point list.
	var index: int = randi() % spawn_points.get_child_count() + 0
	
	return spawn_points.get_child(index).position


func _on_boundary_entered(object: Node) -> void:
	"""
	Respawns the player when it enters the world boundary.
	"""
	
	if object is Player:
		object.death()
