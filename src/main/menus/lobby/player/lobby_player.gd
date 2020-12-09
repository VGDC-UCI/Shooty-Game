"""
Handles basic information for a player that is inside
of the lobby.

Author: Jacob Singleton
"""


extends Control


var _username: String
var _host: bool = false


func get_username() -> String:
	"""
	Returns the username of the player in the lobby.
	"""
	
	return _username


func set_username(username: String) -> void:
	"""
	Sets the username of the player in the lobby.
	"""
	
	_username = username


func is_host() -> bool:
	"""
	Returns true if the player is the host.
	"""
	
	return _host


func set_host(host: bool) -> void:
	"""
	Sets whether the current player should be the host or not.
	"""
	
	_host = host
