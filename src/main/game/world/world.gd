"""
Empty Script for Level stuff. May be useful later

Author: Srayan Jana, Kang Rui Yu
"""


extends Node2D


func _ready() -> void:
	"""
	Called when the world is first loaded, loads in all the
	players and sets up the world.
	"""
	
	var players = server.get_players()
	var spawned_players = []
	
	for player in players:
		var player_id = int(player.get_name())
		var spawn_point: Vector2 = _get_random_spawn_point()
		
		while _player_near_spawn_point(spawn_point, spawned_players):
			spawn_point = _get_random_spawn_point()
		
		player.position = spawn_point
		
		$Players.add_child(player)
		spawned_players.append(player)
	
	$ScoreboardLayer/Scoreboard.initialize_board($Players.get_children())


func _get_random_spawn_point() -> Vector2:
	"""
	Returns a random spawn point.
	"""
	
	var spawn_points = $SpawnPoints
	
	# Picks a random number between 0 and the size of the spawn point list.
	var index: int = randi() % spawn_points.get_child_count()
	
	return spawn_points.get_child(index).position


func _player_near_spawn_point(spawn_point: Vector2, spawned_players) -> bool:
	"""
	Returns true if there is a player near the given spawn point.
	"""
	
	for player in spawned_players:
		if spawn_point.distance_to(player.position) <= 1000:
			return true
	
	return false


func _on_boundary_entered(object: Node) -> void:
	"""
	Respawns the player when it enters the world boundary.
	"""
	
	if object is Player:
		object.position = _get_random_spawn_point()
