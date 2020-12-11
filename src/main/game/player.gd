"""
Class that handles information for a singular player.

Author: Jacob Singleton
"""


extends Node


var _username: String
var _host: bool = false
var _team: int = 1
var _character: int = 0

var _x: float = 0
var _y: float = 0

var _facing_direction: int = 0
var _gun_position: int = 0
var _player_state: int = 0
var _x_input: float = 0


func get_username() -> String:
	"""
	Returns the username of the player.
	"""
	
	return _username


func set_username(username: String) -> void:
	"""
	Sets the username of the player.
	"""
	
	_username = username


func is_host() -> bool:
	"""
	Returns true if this player is set as a host.
	"""
	
	return _host


func set_host(host: bool) -> void:
	"""
	Sets whether or not this player is a host.
	"""
	
	_host = host


func get_x() -> float:
	"""
	Return the x position of the player.
	"""
	
	return _x


func set_x(x: float) -> void:
	"""
	Set the x position of the player.
	"""
	
	_x = x


func get_y() -> float:
	"""
	Return the y position of the player.
	"""
	
	return _y


func set_y(y: float) -> void:
	"""
	Set the y position of the player.
	"""
	
	_y = y


func get_facing_direction() -> int:
	"""
	Returns the player's facing direction.
	"""
	
	return _facing_direction


func set_facing_direction(facing_direction: int) -> void:
	"""
	Sets the facing direction of the player.
	"""
	
	_facing_direction = facing_direction


func get_gun_position() -> int:
	"""
	Returns the gun position of the player.
	"""
	
	return _gun_position


func set_gun_position(gun_position: int) -> void:
	"""
	Sets the gun position of the player.
	"""
	
	_gun_position = gun_position


func get_player_state() -> int:
	"""
	Returns the player state of the player.
	"""
	
	return _player_state


func set_player_state(player_state: int) -> void:
	"""
	Sets the player state of this player.
	"""
	
	_player_state = player_state


func get_x_input() -> float:
	"""
	Returns the x input of the player.
	"""
	
	return _x_input


func set_x_input(x_input: float) -> void:
	"""
	Sets the x input of the player.
	"""
	
	_x_input = x_input


func get_team() -> int:
	"""
	Returns the team the player is on.
	"""
	
	return _team


func set_team(team: int) -> void:
	"""
	Sets what team this player is on.
	"""
	
	_team = team


func get_character() -> int:
	"""
	Returns the character the player is playing.
	"""
	
	return _character


func set_character(character: int) -> void:
	"""
	Sets the character this player is playing.
	"""
	
	_character = character
