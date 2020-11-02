extends KinematicBody2D

class_name Player

# Constants
const GRAVITY := 1200

# Player Properties
var player_name := ""
export var score_worth := 1
var spawn_point := Vector2()
export var default_health = 10
# Player States
export (int) onready var player_health = default_health
puppet var score := 0

# Shield Properties
export var default_shield := 10
# Shield States
var shield_pressed := false
export (int) onready var shield_health := default_shield

# Movement Properties
export var player_acceleration := 1800.0
export var player_damp := 0.7
# Movement States
var x_input := 0.0
var y_input := 0.0
var velocity := Vector2()
puppet var player_velocity := Vector2()
puppet var player_position := Vector2()
puppet var facing_left := false

# Jumping Properties
export var jump_force := 600
export var air_jumps := 2 # Number of air jumps
# Jumping States
var air_jumps_left = air_jumps
var	jump_persistance_time_frame := 0.2 # The time frame after the last jump press will still activate
var jump_persistance_time_left := 0.0 # The current time frame left for jump to be called
var on_ground_persistance_time_frame := 0.2 # The time frame since last ground touch that will still count as on ground
var on_ground_persistance_time_left := 0.0 # The current time frame left for on ground to be true
var half_jump := false

# Dash Properties
export var dash_force := 5000
# Dash States
puppet var is_dashing := false
puppet var can_dash := false
puppet var dash_direction := Vector2()

# Wall Slide Properties
export var wall_slide_speed := 150
# Wall Slide States
puppet var wall_sliding = false

# Combat Properties
var bullet_exit_radius := 54.0
export var bullet_speed := 500.0
export var bullet_damage := 1.0
export var bullet_scale := 1.0
export var fire_rate := 0.2
# Combat States
puppet var who_is_attacking
puppet var is_shooting := false
puppet var shoot_direction := Vector2()
var bullet_template = preload("res://Scenes/Bullet.tscn")
var time_left_till_next_bullet = fire_rate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_player_name(player_name)
	player_position = position
	self.add_to_group("Collision")
	self.add_to_group("Hittable")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_input(delta)
	update_state(delta)
	set_camera()
	# send information to ui, make this a function later
	get_node("DebugLabel").text = to_string()
	get_node("NameLabel").set_text(player_name + ", " + str(score))
	

func get_movement_input() -> void:
	x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#y_input = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	# Check for facing direction
	if x_input >= 0:
		facing_left = false
	else:
		facing_left = true
		

func get_jumping_input(delta: float) -> void:
	if Input.is_action_just_pressed("jump_pressed"):
		jump_persistance_time_left = jump_persistance_time_frame
	elif jump_persistance_time_left > 0:
		jump_persistance_time_left -= delta
		jump_persistance_time_left = clamp(jump_persistance_time_left, 0, jump_persistance_time_frame)
	half_jump = Input.is_action_just_released("jump_pressed")
	

func get_dashing_input() -> void:
	is_dashing = Input.is_action_just_pressed("dash")
	can_dash = is_on_floor() or !is_on_floor()

	if Input.is_action_pressed("move_right"):
		dash_direction = Vector2(1,0)
		#print(dash_direction)
	if Input.is_action_pressed("move_left"):
		dash_direction = Vector2(-1,0)

	rset("dash_direction", dash_direction)
	rset("is_dashing", is_dashing)
	rset("can_dash", can_dash)
	

func get_shooting_input() -> void:
	is_shooting = Input.is_action_pressed("shoot")

	var mouse_direction := get_position().direction_to(get_global_mouse_position()) # getting direction to mouse
	var bullet_angle := atan2(mouse_direction.y, mouse_direction.x)
	shoot_direction = Vector2(cos(bullet_angle), sin(bullet_angle))

	rset("is_shooting", is_shooting)
	rset("shoot_direction", shoot_direction) # Make sure that the other instances can see this
	

func get_shield_input() -> void:
	shield_pressed = Input.is_action_pressed("shield")

	
func get_wall_sliding_input() -> void:
	rset("wall_sliding", wall_sliding)


func get_input(delta: float) -> void:
	if is_network_master():
		get_movement_input()
		get_jumping_input(delta)
		get_dashing_input()
		get_shooting_input()
		get_shield_input()
		get_wall_sliding_input()


func apply_movement(delta: float) -> void:
	velocity.x += x_input * player_acceleration * delta
	velocity.x *= pow(player_damp, delta * 10.0)
	

func apply_jump() -> void:
	if jump_persistance_time_left > 0 and on_ground_persistance_time_left > 0: # Jumping off ground
		jump()
		air_jumps_left = air_jumps
		print("normal_jump")
		print(str(velocity))
	elif jump_persistance_time_left > 0 and is_on_wall(): # Jumping off wall
		jump()
		print("wall_jump")
		print(str(velocity))
	elif jump_persistance_time_left > 0 and air_jumps_left > 0: # Jumping in air
		jump()
		air_jumps_left -= 1
		print("air_jumps_left: " + str(air_jumps_left))
		print(str(velocity))
	elif half_jump and velocity.y < 0: # Half jumping
		velocity.y *= 0.5
		

func jump() -> void:
	velocity.y = -jump_force
	jump_persistance_time_left = 0
		

func apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		on_ground_persistance_time_left = on_ground_persistance_time_frame
		air_jumps_left = air_jumps
	else:
		velocity.y += GRAVITY * delta
		on_ground_persistance_time_left -= delta
		on_ground_persistance_time_left = clamp(on_ground_persistance_time_left, 0, on_ground_persistance_time_frame)
		

func apply_wall_slide() -> void:
	if is_on_wall() and velocity.y > wall_slide_speed:
		velocity.y = wall_slide_speed
		

func apply_dash() -> void:
	if can_dash and is_dashing:
		print(can_dash)
		print(is_dashing)
		dash()
		can_dash = false


func dash() -> void:
	velocity = dash_direction * dash_force
	can_dash = false
	get_tree().create_timer(0.3)
	is_dashing = false
	

func apply_shooting(delta) -> void:
	set_shoot_position()
	do_attack(delta)


func set_shoot_position() -> void:
	get_node("BulletExit").position = shoot_direction * bullet_exit_radius + self.position


func do_attack(delta: float) -> void:
	time_left_till_next_bullet -= delta
	if is_shooting and time_left_till_next_bullet <= 0:
		var bullet = bullet_template.instance()
		bullet.set_direction(shoot_direction)
		bullet.bullet_speed = bullet_speed
		bullet.bullet_damage = bullet_damage
		bullet.position = get_node("BulletExit").position
		bullet.scale *= bullet_scale
		bullet.parent_node = self
		get_tree().get_root().add_child(bullet)
		time_left_till_next_bullet = fire_rate


func update_state(delta: float) -> void: # Updates state
	velocity = player_velocity
	
	if is_network_master():
		apply_gravity(delta)
		apply_movement(delta)
		apply_jump()
		apply_wall_slide()
		apply_dash()
		apply_shooting(delta)

		rset("player_velocity", velocity)
		player_velocity = velocity # so i can save the data of this velocity to use elsewhere
		rset_unreliable("player_position", position)
	else:
		position = player_position
		velocity = player_velocity
	
	move_and_slide(velocity, Vector2(0, -1)) #added a floor 
	
	if not is_network_master():
		player_position = position # To avoid jitter

#this is inefficent
func set_camera() -> void:
	if is_network_master():
		for player in get_parent().get_children():
			if(player == self):
				player.get_node("Camera2D").current = true
			else:
				player.get_node("Camera2D").current = false
			pass


func set_attacking(player_responsible: Player) -> void:
	# this is so that the last person who hits the player gets the kill
	who_is_attacking = player_responsible
	rset("who_is_attacking", who_is_attacking)


func on_hit(damage: float) -> void:
	if shield_health > 0:
		shield_health -= damage
	elif player_health > 0:
		player_health -= damage
	else:
		who_is_attacking.add_to_score(score_worth)
		death()


func death() -> void:
	#RESPAWN
	shield_health = default_shield
	player_health = default_health
	score -= 1
	position = spawn_point
	rset("player_position", position)
	rset("score", score)


func add_to_score(points: int) -> void:
	score += points
	rset("score", score)


func set_player_name(new_name: String) -> void:
	player_name = new_name


func _to_string() -> String:
	var player_string := ""
	player_string += "Current State: "
	
	player_string += "\n"
	
	player_string += "Health:" + str(player_health) + "\n"
	
	player_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(shield_health) + "\n"
	
	player_string += "Shooting: " + str(is_shooting) + "\n"
	
	player_string += "Shoot Direction" + str(shoot_direction) + "\n"

	return player_string
