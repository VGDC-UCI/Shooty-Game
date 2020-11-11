"""
Handles inputs from client and inputs them into the player state machine.

Author: Srayan Jana
"""

extends KinematicBody2D

class_name Player

# Constants
const GRAVITY := 1200
enum States {GROUND, AIR, WALL}

# Player Properties
var player_name := ""
export var score_worth := 1
var spawn_point := Vector2()
export var default_health = 10
# Player States
export (int) onready var player_health = default_health
puppet var numb_of_kills := 0
puppet var numb_of_deaths := 0
export (States) puppet var current_state := States.AIR

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
var jumped: bool = false

# Dash Properties
export var dash_force := 1300
onready var dash_timer = $dash_timer
onready var dash_particles = $dash_particles
export(PackedScene) var dash_object
export var dash_length := 0.25
export var dash_times := 1
var dash_left = dash_times
# Dash States
puppet var is_dashing := false
puppet var can_dash := false
puppet var dash_direction := Vector2()
#gun stuff
onready var gun := $Position2D/gun
onready var gun_hold :=$Position2D
var deg_gun : float


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

# Animations
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
var air_animation1: bool = false # Whether to play the first air animation or second


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_player_name(player_name)
	player_position = position
	self.add_to_group("Collision")
	self.add_to_group("Hittable")
	dash_timer.connect("timeout",self,"dash_timer_timeout")
	pass # Replace with function body.
	

func _process(_delta: float) -> void:
	update_animations()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_state()
	apply_state(delta)
	set_shoot_position()
	do_attack(delta)
	set_camera()
	# send information to ui, make this a function later
	get_node("DebugLabel").text = to_string()
	get_node("NameLabel").set_text(player_name + ", K: " + str(numb_of_kills) + " / D: " + str(numb_of_deaths))
	#get_node("gun").look_at(get_global_mouse_position())


func update_animations() -> void:
	if is_network_master():
		animated_sprite.flip_h = shoot_direction.x > 0
		gun_move()
		match current_state:
			States.GROUND:
				if x_input != 0:
					animated_sprite.play('run')
				else:
					animated_sprite.play('idle')
			States.AIR:
				if jumped:
					air_animation1 = not air_animation1
				if air_animation1:
					animated_sprite.play('air')
				else:
					animated_sprite.play('air2')
			States.WALL:
				pass
	

func update_state() -> void: # Detects for state transitions
	if is_network_master():
		match current_state:
			States.GROUND:
				if not is_on_floor():
					current_state = States.AIR
			States.AIR:
				if is_on_floor():
					current_state = States.GROUND
				elif is_on_wall():
					current_state = States.WALL
			States.WALL:
				if not is_on_wall():
					current_state = States.AIR
				elif is_on_floor():
					current_state = States.GROUND
		rset("current_state", current_state)


func apply_state(delta: float) -> void: # Apply the functions of the current state
	velocity = player_velocity
	
	if is_network_master():
		match current_state:
			States.GROUND:
				apply_gravity(delta) # Gravity must be applied on every state or is_on_ground() won't work correctly. (Apply before everything else)
				apply_movement(delta)
				apply_jump()
				apply_dash()
			States.AIR:
				apply_gravity(delta)
				apply_movement(delta)
				apply_jump()
				apply_dash()
				apply_wall_slide()
			States.WALL:
				apply_gravity(delta)
				apply_movement(delta)
				apply_jump()
				apply_dash()
				apply_wall_slide()

		rset("player_velocity", velocity)
		player_velocity = velocity # so i can save the data of this velocity to use elsewhere
		rset_unreliable("player_position", position)
	else:
		position = player_position
		velocity = player_velocity
	
	move_and_slide(velocity, Vector2(0, -1)) #added a floor 
	
	if not is_network_master():
		player_position = position # To avoid jitter


func apply_movement(delta: float) -> void:
	velocity.x += x_input * player_acceleration * delta
	velocity.x *= pow(player_damp, delta * 10.0)
	

func apply_jump() -> void:
	jumped = false
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
	jumped = true
		

func apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = GRAVITY * delta
		on_ground_persistance_time_left = on_ground_persistance_time_frame
		air_jumps_left = air_jumps
		dash_left = dash_times
	else:
		velocity.y += GRAVITY * delta
		on_ground_persistance_time_left -= delta
		on_ground_persistance_time_left = clamp(on_ground_persistance_time_left, 0, on_ground_persistance_time_frame)
		

func apply_wall_slide() -> void:
	if is_on_wall() and velocity.y > wall_slide_speed:
		velocity.y = wall_slide_speed
		

func apply_dash() -> void:
	if can_dash and is_dashing and dash_left > 0:
		print(can_dash)
		print(is_dashing)
		dash()
		can_dash = false


func gun_move() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	deg_gun = mouse_pos.angle_to_point(gun.global_position)
	gun_hold.look_at(mouse_pos)
	if global_position.x > mouse_pos.x:
		gun.scale.y = -1
	else:
		gun.scale.y = 1


func dash() -> void:
	velocity = dash_direction * dash_force
	dash_left -= 1
	can_dash = false
	var dash_node = dash_object.instance()
	dash_timer.start(dash_length)
	dash_particles.emitting = true
	if(is_on_wall()):
		is_dashing = false
	is_dashing = false


func dash_timer_timeout() -> void:
	is_dashing = false


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
		who_is_attacking.add_to_numb_of_kills(score_worth)
		death()


func death() -> void:
	#RESPAWN
	shield_health = default_shield
	player_health = default_health
	numb_of_deaths += 1
	position = spawn_point
	rset("player_position", position)
	rset("numb_of_deaths", numb_of_deaths)


func add_to_numb_of_kills(points: int) -> void:
	numb_of_kills += points
	rset("numb_of_kills", numb_of_kills)


func set_player_name(new_name: String) -> void:
	player_name = new_name


func _to_string() -> String:
	var player_string := ""

	player_string += "Current State: "
	match current_state:
		States.GROUND:
			player_string += "GROUND\n" 
		States.AIR:
			player_string += "AIR\n"
		States.WALL:
			player_string += "WALL\n"
	
	player_string += "\n"
	
	player_string += "Health:" + str(player_health) + "\n"
	
	player_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(shield_health) + "\n"
	
	player_string += "Can Dash: " + str(can_dash) + "\nIs Dashing:" + str(is_dashing) + "\n"
	
	player_string += "Shooting: " + str(is_shooting) + "\n"
	
	player_string += "Shoot Direction" + str(shoot_direction) + "\n"

	return player_string
