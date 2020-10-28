# Respawns the player on top of the level if they fall off the world.


extends Area2D


func _on_deadline_entered( entered_object: Node ) -> void:
	'Respawns the object entering the deadline if it is a player'
	
	if entered_object is Player:
		entered_object.death()

