"""
Handles inputs from client and inputs them into the player state machine.

Author: Srayan Jana, Kang Rui Yu, Daniel Lu
"""


extends KinematicBody2D

class_name Player


enum PlayerState {
	GROUND, AIR, WALL
}


"Player Variables"
var _local_camera: bool = true

var _username: String
var _host: bool = false
var _team: int = 1
var _character: String

const _MAX_SHIELD: int = 10
var _shield:       int = _MAX_SHIELD

const _MAX_HEALTH: int = 10
var _health:       int = _MAX_HEALTH

var _kills: int = 0
var _deaths: int = 0

var _player_state = PlayerState.AIR

"Movement Variables"
const _GRAVITY: int = 1200
const _PLAYER_ACCELERATION: float = 1800.0
const _PLAYER_DAMP: float = 0.7

var _x_input := 0.0
var _velocity := Vector2()

"Jumping Variables"
var _jump_force: int = 600

var _max_air_jumps: int = 2
var _air_jumps: int = _max_air_jumps

# The time frame after the last jump press will still activate.
var _jump_persistance_time_frame: float = 0.2
# The current time frame left for jump to be called.
var _jump_persistance_time_left: float = 0.0

# The time frame since last ground touch that will still count as on ground.
var _on_ground_persistance_time_frame: float = 0.2
# The current time frame left for on ground to be true.
var _on_ground_persistance_time_left: float = 0.0

var half_jump: bool = false
var jumped: bool = false

"Dash Variables"
var _dash_force: int = 1300

onready var _dash_timer = $Dashing/DashTimer
onready var _dash_particles = $Dashing/DashParticles

export (PackedScene) var dash_object

export var _dash_cooldown: int = 1
export var _max_dashes: int = 1
var _dashes = _max_dashes

puppet var is_dashing: bool = false
puppet var can_dash: bool = false
puppet var dash_direction := Vector2()

"Gun Variables"
onready var gun := $Position2D/gun
onready var gun_hold :=$Position2D
var deg_gun : float

"Wall Slide Properties"
export var wall_slide_speed := 150

"Wall Slide States"
puppet var wall_sliding = false

"Combat Properties"
var bullet_exit_radius := 54.0
export var bullet_speed := 500.0
export var bullet_damage := 1.0
export var bullet_scale := 1.0
export var fire_rate := 0.2

"Combat States"
puppet var who_is_attacking
puppet var is_shooting := false
puppet var shoot_direction := Vector2()
var bullet_template = preload("res://src/main/game/bullet/Bullet.tscn")
var time_left_till_next_bullet = fire_rate

"Animations"
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
var air_animation1: bool = false # Whether to play the first air animation or second

"UI"
var show_status_bars: bool = false
export (bool) var debug_mode: bool = false


func _ready() -> void:
	"""
	Called when the player is spawned.
	Makes connections for the dash timer and sets their name.
	"""
	
	$PlayerInformation/Name.text = _username
	_dash_timer.connect("timeout", self, "dash_timer_timeout")


func get_username() -> String:
	"""
	Returns the username of the player.
	"""
	
	return _username


func set_username(username: String) -> void:
	"""
	Sets the username of the player.
	"""
	
	_username = username


func is_host() -> bool:
	"""
	Returns true if this player is the host.
	"""
	
	return _host


func set_host(host: bool) -> void:
	"""
	Sets whether or not this player is the host.
	"""
	
	_host = host


func _process(_delta: float) -> void:
	update_animations()
	update_ui()


func update_animations() -> void:
	animated_sprite.flip_h = shoot_direction.x > 0

	gun_move()

	# Scale Sprite based on velocity
	animated_sprite.scale.x = 0.12 * (1 + 0.05 * (abs(_velocity.x) / 500))
	animated_sprite.scale.x = clamp(animated_sprite.scale.x, 0.12, 0.14)
	animated_sprite.scale.y = 0.12 * (1 + 0.1 * (abs(_velocity.y) / 500))
	animated_sprite.scale.y = clamp(animated_sprite.scale.y, 0.12, 0.13)

	match _player_state:
		PlayerState.GROUND:
			if _x_input != 0:
				animated_sprite.play('run')
			else:
				animated_sprite.play('idle')
		PlayerState.AIR:
			if jumped:
				air_animation1 = not air_animation1
			if air_animation1:
				animated_sprite.play('air')
			else:
				animated_sprite.play('air2')
		PlayerState.WALL:
			pass


func update_ui() -> void:
	if show_status_bars:
		$PlayerInformation/HealthBar.value = _health
		$PlayerInformation/ShieldBar.value = _shield


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_state()
	apply_state(delta)
	set_shoot_position()
	do_attack(delta)
	
	if _local_camera:
		set_camera()


func update_state() -> void: # Detects for state transitions
	match _player_state:
		PlayerState.GROUND:
			if not is_on_floor():
				_player_state = PlayerState.AIR
		PlayerState.AIR:
			if is_on_floor():
				_player_state = PlayerState.GROUND
			elif is_on_wall():
				_player_state = PlayerState.WALL
		PlayerState.WALL:
			if not is_on_wall():
				_player_state = PlayerState.AIR
			elif is_on_floor():
				_player_state = PlayerState.GROUND


func apply_state(delta: float) -> void: # Apply the functions of the current state
	match _player_state:
		PlayerState.GROUND:
			apply_gravity(delta) # Gravity must be applied on every state or is_on_ground() won't work correctly. (Apply before everything else)
			apply_movement(delta)
			apply_jump()
			apply_dash()
		PlayerState.AIR:
			apply_gravity(delta)
			apply_movement(delta)
			apply_jump()
			apply_dash()
			apply_wall_slide()
		PlayerState.WALL:
			apply_gravity(delta)
			apply_movement(delta)
			apply_jump()
			apply_dash()
			apply_wall_slide()

	move_and_slide(_velocity, Vector2(0, -1)) #added a floor

	if is_network_master():
		# player_position = position # To avoid jitter
		rset_unreliable("player_position", position)
		rset('velocity', _velocity)


func apply_movement(delta: float) -> void:
	_velocity.x += _x_input * _PLAYER_ACCELERATION * delta
	_velocity.x *= pow(_PLAYER_DAMP, delta * 10.0)


func apply_jump() -> void:
	jumped = false
	if _jump_persistance_time_left > 0 and _on_ground_persistance_time_left > 0: # Jumping off ground
		jump()
		_air_jumps = _max_air_jumps
		print("normal_jump")
		print(str(_velocity))
	elif _jump_persistance_time_left > 0 and is_on_wall(): # Jumping off wall
		jump()
		print("wall_jump")
		print(str(_velocity))
	elif _jump_persistance_time_left > 0 and _air_jumps > 0: # Jumping in air
		jump()
		_air_jumps -= 1
		print("air_jumps_left: " + str(_air_jumps))
		print(str(_velocity))
	elif half_jump and _velocity.y < 0: # Half jumping
		_velocity.y *= 0.5


func jump() -> void:
	_velocity.y = -_jump_force
	_jump_persistance_time_left = 0
	jumped = true


func apply_gravity(delta: float) -> void:
	if is_on_floor():
		_velocity.y = _GRAVITY * delta
		_on_ground_persistance_time_left = _on_ground_persistance_time_frame
		_air_jumps = _max_air_jumps
		_dashes = _max_dashes
	else:
		_velocity.y += _GRAVITY * delta
		_on_ground_persistance_time_left -= delta
		_on_ground_persistance_time_left = clamp(_on_ground_persistance_time_left, 0, _on_ground_persistance_time_frame)


func apply_wall_slide() -> void:
	if is_on_wall() and _velocity.y > wall_slide_speed:
		_velocity.y = wall_slide_speed


func apply_dash() -> void:
	if can_dash and is_dashing and _dashes > 0 and _dash_timer.is_stopped():
		print(can_dash)
		print(is_dashing)
		dash()
		can_dash = false


func gun_move() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	deg_gun = mouse_pos.angle_to_point(gun.global_position)
	gun_hold.look_at(global_position + shoot_direction)
	if shoot_direction.x < 0:
		gun.scale.y = -1
	else:
		gun.scale.y = 1


func dash() -> void:
	_velocity = dash_direction * _dash_force
	_dashes -= 1
	can_dash = false
	var dash_node = dash_object.instance()
	_dash_timer.start(_max_dashes)
	_dash_particles.emitting = true
	if(is_on_wall()):
		is_dashing = false
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


func toggle_status_bars() -> void:
	show_status_bars = not show_status_bars


#this is inefficent
func set_camera() -> void:
	if is_network_master():
		for player in get_parent().get_children():
			if(player == self):
				player.get_node("Camera2D").current = true
			else:
				player.get_node("Camera2D").current = false
			pass


func set_attacking(player_responsible) -> void:
	# this is so that the last person who hits the player gets the kill
	who_is_attacking = player_responsible
	#rset("who_is_attacking", who_is_attacking)


func on_hit(damage: float) -> void:
	if not show_status_bars:
		toggle_status_bars()

	if _shield > 0:
		_shield -= damage
	elif _health > 0:
		_health -= damage
	else:
		who_is_attacking.add_to_numb_of_kills(1)
		death()


func death() -> void:
	#RESPAWN
	_shield = _MAX_SHIELD
	_health = _MAX_HEALTH
	_deaths += 1
	if show_status_bars:
		toggle_status_bars()


func add_to_numb_of_kills(points: int) -> void:
	_kills += points
