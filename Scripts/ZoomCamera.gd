extends Camera2D

# Properties
export var move_speed: float = 5
export var zoom_speed: float = 5
export var min_zoom: float = 1
export var max_zoom: float = 5
export var buffer = Vector2(400, 200)
# States
var targets: Array = []
onready var screen_size: Vector2 = get_viewport().size


func _process(delta: float) -> void:
	if targets.empty():
		set_process(false)
		return
		
	center(delta)
	zoom(delta)


func center(delta: float) -> void: # Centers the camera among the targets
	var center: Vector2 = Vector2()
	for target in targets:
		center += target.global_position
	center /= targets.size()
	global_position = lerp(global_position, center, clamp(move_speed * delta, 0, 1))
	

func zoom(delta: float) -> void: # Zooms the camera to fit all targets
	var bounds: Rect2 = Rect2(position, Vector2.ONE)
	for target in targets:
		bounds = bounds.expand(target.global_position)
	bounds = bounds.grow_individual(buffer.x, buffer.y, buffer.x, buffer.y)
	
	var new_zoom: float
	if bounds.size.x > bounds.size.y * screen_size.aspect():
		new_zoom = bounds.size.x / screen_size.x
	else:
		new_zoom = bounds.size.y / screen_size.y
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * new_zoom, clamp(zoom_speed * delta, 0, 1))
