extends StaticBody2D

class_name Enemy


var score_worth: int = 1

export var max_health: float = 10
export var current_health: float = max_health

export var max_shield: float = 10
export var current_shield: float = max_shield

var shield_pressed: bool = false

puppet var who_is_attacking


func _ready() -> void:
	'Called when the enemy is spawned.'
	
	add_to_group( "Collision" )
	add_to_group( "Hittable" )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func set_attacking(player_responsible):
	# this is so that the last person who hits the player gets the kill
	who_is_attacking = player_responsible
	pass


func on_hit(damage):
	current_health -= damage
	if(current_shield > 0):
		current_shield -= damage
	elif(current_health > 0):
		current_health -= damage
	else:
		who_is_attacking.add_to_numb_of_kills(score_worth)
		death()
	pass

func death():
	queue_free()
	pass

func _to_string():
	var enemy_string := ""
	
	enemy_string += "Health:" + str(current_health) + "\n"
	
	enemy_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(current_shield) + "\n"
	
	return enemy_string
