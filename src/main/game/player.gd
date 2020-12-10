"""
Class that handles information for a singular player.

Author: Jacob Singleton
"""


extends Node


var _username: String
var _host: bool = false

var _x: float = 0
var _y: float = 0

var _facing_direction: int = 0
var _gun_position: int = 0


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
