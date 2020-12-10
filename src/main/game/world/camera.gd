"""
A camera that zooms and moves to fit all its targets

Author: Kang Rui Yu
"""


extends Camera2D


"Camera Properties"
export var _move_speed: float = 5
export var _zoom_speed: float = 5
export var _min_zoom: float = 1
export var _max_zoom: float = 5
export var _buffer = Vector2(400, 200)

"Camera State"
export var _targets: Array = []
onready var _screen_size: Vector2 = get_viewport().size


func _process(delta: float) -> void:
	"""
	Called every frame. Moves the camera to the correct position.
	"""
	if not _targets.empty():
		center(delta)
		zoom(delta)


func center(delta: float) -> void:
	"""
	Centers the camera around targets on the screen.
	"""
	
	var center := Vector2()
	
	for target in _targets:
		center += target.global_position
	
	center /= _targets.size()
	
	global_position = lerp(global_position, center, clamp(_move_speed * delta, 0, 1))


func zoom(delta: float) -> void:
	"""
	Zooms in the camera to fit all targets.
	"""
	
	var bounds: Rect2 = Rect2(position, Vector2.ONE)
	
	for target in _targets:
		bounds = bounds.expand(target.global_position)
	
	bounds = bounds.grow_individual(_buffer.x, _buffer.y, _buffer.x, _buffer.y)

	var new_zoom: float
	
	if bounds.size.x > bounds.size.y * _screen_size.aspect():
		new_zoom = bounds.size.x / _screen_size.x
	else:
		new_zoom = bounds.size.y / _screen_size.y
		
	new_zoom = clamp(new_zoom, _min_zoom, _max_zoom)
	
	zoom = lerp(zoom, Vector2.ONE * new_zoom, clamp(_zoom_speed * delta, 0, 1))
