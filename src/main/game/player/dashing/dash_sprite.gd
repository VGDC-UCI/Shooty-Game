"""
Handles the display of the dash sprite.

Author: Kang Rui Yu
"""


extends Sprite


func _physics_process(delta: float):
	"""
	Handles the dash sprite animation.
	"""
	
	modulate.a = lerp(modulate.a, 0, 0.01)
	
	if modulate.a < 0.01:
		queue_free()
