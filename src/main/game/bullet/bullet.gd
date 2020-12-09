"""
Handles interactions with a bullet after it is fired.

Author: Srayan Jana
"""


extends KinematicBody2D


export var bullet_speed: float = 100
export var bullet_damage: float = 1
export var life_span: float = 60 # In seconds.
var bullet_direction: Vector2 = Vector2(1, 0)

var parent_node := KinematicBody2D.new()


func _physics_process( delta: float ) -> void:
	"""
	Called every frame and moves the bullet every frame. Destroys the bullet
	if it's been alive for too long.

	delta: The amount of time since the last frame.
	"""

	life_span -= delta

	if life_span > 0:
		move_and_slide( bullet_speed * bullet_direction )
	else:
		destroy()


func set_direction( direction: Vector2 ) -> void:
	"""
	Sets the direction of the bullet.

	direction: The new direction of the bullet.
	"""

	bullet_direction = direction


func _on_hit( hit_object: Node ) -> void:
	"""
	Called when the bullet hits an object. Destroys the bullet and
	damages a player if one was hit.
	"""

	if hit_object == parent_node:
		return

	if hit_object.has_method('do_attack') and hit_object.team == parent_node.team: # Can't check "is_class", causes error
		destroy()
		return

	if hit_object.is_in_group( "Hittable" ):
		hit_object.on_hit( bullet_damage )
		hit_object.set_attacking( parent_node )
		destroy()

	destroy()


func destroy() -> void:
	"""
	Destroys the bullet.
	"""

	queue_free()

