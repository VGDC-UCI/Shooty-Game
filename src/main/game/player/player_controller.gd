"""
Takes in inputs and inputs them into player behavior

Author: Srayan Jana, Kang Rui Yu
"""

extends Node2D

# References
onready var player: Player = get_parent()
# States
var control_scheme: Dictionary = ControlSchemes.get_scheme_data(0)
var using_controller: bool = false


func _physics_process(delta: float) -> void:
	get_input(delta)


func get_input(delta: float) -> void:
	if is_network_master():
		match player.current_state:
			player.States.GROUND:
				get_movement_input()
				get_jumping_input(delta)
				get_dashing_input()
				get_shooting_input()
				get_shield_input()
			player.States.AIR:
				get_movement_input()
				get_jumping_input(delta)
				get_dashing_input()
				get_shooting_input()
				get_shield_input()
			player.States.WALL:
				get_movement_input()
				get_jumping_input(delta)
				get_dashing_input()
				get_shooting_input()
				get_shield_input()
				get_wall_sliding_input()


func get_movement_input() -> void:
	player.x_input = Input.get_action_strength(control_scheme["right"]) - Input.get_action_strength(control_scheme["left"])
	#y_input = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# Check for facing direction
	if player.x_input > 0:
		player.facing_left = false
	elif player.x_input < 0:
		player.facing_left = true
	player.rset('x_input', player.x_input)


func get_jumping_input(delta: float) -> void:
	if Input.is_action_just_pressed(control_scheme["jump"]):
		player.jump_persistance_time_left = player.jump_persistance_time_frame
	elif player.jump_persistance_time_left > 0:
		player.jump_persistance_time_left -= delta
		player.jump_persistance_time_left = clamp(player.jump_persistance_time_left, 0, player.jump_persistance_time_frame)
	player.half_jump = Input.is_action_just_released(control_scheme["jump"])


func get_dashing_input() -> void:
	player.is_dashing = Input.is_action_just_pressed(control_scheme["dash"])
	player.can_dash = player.is_on_floor() or !player.is_on_floor()

	if Input.is_action_pressed(control_scheme["right"]):
		player.dash_direction = Vector2(1,0)
		#print(dash_direction)
	if Input.is_action_pressed(control_scheme["left"]):
		player.dash_direction = Vector2(-1,0)

	player.rset("dash_direction", player.dash_direction)
	player.rset("is_dashing", player.is_dashing)
	player.rset("can_dash", player.can_dash)


func get_shooting_input() -> void:
	player.is_shooting = Input.is_action_pressed(control_scheme["shoot"])

	var direction: Vector2
	if not using_controller:
		direction = player.get_position().direction_to(get_global_mouse_position()) # getting direction to mouse
	else:
		direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3)).normalized()
	var bullet_angle := atan2(direction.y, direction.x)
	player.shoot_direction = Vector2(cos(bullet_angle), sin(bullet_angle))

	player.rset("is_shooting", player.is_shooting)
	player.rset("shoot_direction", player.shoot_direction) # Make sure that the other instances can see this


func get_shield_input() -> void:
	player.shield_pressed = Input.is_action_pressed(control_scheme["shield"])


func get_wall_sliding_input() -> void:
	player.rset("wall_sliding", player.wall_sliding)

