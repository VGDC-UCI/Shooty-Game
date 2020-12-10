"""
Handles inputs from client and inputs them into the player state machine.

Author: Srayan Jana, Kang Rui Yu, Daniel Lu, & Jacob Singleton
"""


extends KinematicBody2D

class_name Player


enum PlayerState {
	GROUND,
	AIR,
	WALL
}


enum FacingDirection {
	RIGHT,
	LEFT
}


"Player Variables"
var _username: String
var _host: bool = false
var _local: bool = false
var _root_player: bool = false
var _team: int = 1
var _character_id: int = 0

const _MAX_SHIELD: int = 10
var _shield:       int = _MAX_SHIELD
var _shield_pressed: bool = false

const _MAX_HEALTH: int = 10
var _health:       int = _MAX_HEALTH

var _kills: int = 0
var _deaths: int = 0

var _player_state = PlayerState.AIR

"Movement Variables"
const _GRAVITY: int = 1200
const _PLAYER_ACCELERATION: float = 1800.0
const _PLAYER_DAMP: float = 0.7

var _x_input: float = 0.0
var _velocity := Vector2()
var _controls_id: int
var _facing_direction = FacingDirection.RIGHT

"Jumping Variables"
var _jump_force: int = 600

var _max_jumps: int = 3
var _jumps_left: int = _max_jumps

# The time frame after the last jump press will still activate.
var _jump_time_frame: float = 0.2
# The current time frame left for jump to be called.
var _jump_time_left: float = 0.0

# The time frame since last ground touch that will still count as on ground.
var _on_ground_time_frame: float = 0.2
# The current time frame left for on ground to be true.
var _on_ground_time_left: float = 0.0

"Dash Variables"
var _dash_force: int = 1300

var _max_dashes: int = 1
var _dashes = _max_dashes

var _dash_cooldown: float = 1.5 # In seconds.
var _dash_timer: float = 0
var _dash_direction := Vector2()

"Gun Variables"
var _gun_angle: float

"Wall Sliding Variables"
var _wall_slide_speed: int = 150
var _wall_sliding: bool = false

"Combat Variables"
var _bullet_exit_radius: float = 54.0
var _bullet_scale: float = 1.0
var _fire_rate: float = 0.2

"Combat States"
var _shoot_direction := Vector2()
var _bullet_template = preload("res://src/main/game/bullet/Bullet.tscn")
var _time_left_till_next_bullet = _fire_rate


func _process(_delta: float) -> void:
	"""
	Called every frame, updates the animated sprite and
	player UI.
	"""
	
	_move_player_facing_position()
	_update_player_animations()
	
	if _root_player:
		_move_gun_facing_position()
		_update_health_bar()


func _move_player_facing_position() -> void:
	"""
	Moves the player to the position they are facing.
	"""
	
	$Hitbox/AnimatedSprite.flip_h = _facing_direction == FacingDirection.RIGHT


func _update_player_animations() -> void:
	"""
	Updates the player's sprite animations.
	"""
	
	var animated_sprite: Node = $Hitbox/AnimatedSprite

	# Scale Sprite based on velocity.
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
			if _jump_time_left > 0:
				animated_sprite.play('jumping')
			else:
				animated_sprite.play('falling')
		PlayerState.WALL:
			animated_sprite.play('jumping')


func _move_gun_facing_position() -> void:
	"""
	Moves the gun facing position to where the mouse cursor is pointing.
	"""
	
	var mouse_pos_x: float = get_global_mouse_position().x - position.x
	var old_gun_scale_x: float = $Gun.scale.x
	
	if mouse_pos_x >= 0:
		$Gun.scale.x = 1
		$Gun.position.x = 40
	else:
		$Gun.scale.x = -1
		$Gun.position.x = -40
	
	if old_gun_scale_x != $Gun.scale.x and not _local:
		server.send_change_gun_position($Gun.scale.x)


func _update_health_bar() -> void:
	"""
	Updates the player health and shield bar.
	"""
	
	$BarInformation/HealthBar.value = _health
	$BarInformation/ShieldBar.value = _shield


func _get_controls_mappings() -> Dictionary:
	"""
	Returns the controls mappings for the player.
	"""
	
	return controls.get_control_mappings(_controls_id)


func _get_controls_type() -> int:
	"""
	Gets the id of the player's control scheme.
	"""
	
	return controls.get_control_type(_controls_id)


func _physics_process(delta: float) -> void:
	"""
	Called every frame, calculates physics for the player.
	"""
	
	if _root_player:
		var controls_mappings: Dictionary = _get_controls_mappings()
		
		_update_player_state()
		
		_do_gravity(delta)
		_do_player_movement(controls_mappings, delta)
		_do_dashing(controls_mappings, delta)
		_do_wall_slide()
		
		_move_player()
		_do_shooting(controls_mappings, delta)
		
		_move_camera()


func _update_player_state() -> void:
	"""
	Updates the current state of the player.
	"""
	
	var old_player_state: int = _player_state
	
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
	
	if old_player_state != _player_state and not _local:
		server.send_change_player_state(_player_state)


func _do_gravity(delta: float) -> void:
	"""
	Applies gravity to the player.
	"""
	
	if is_on_floor():
		_velocity.y = _GRAVITY * delta
		_on_ground_time_left = _on_ground_time_frame
		_jumps_left = _max_jumps
		_dashes = _max_dashes
	else:
		_velocity.y += _GRAVITY * delta
		_on_ground_time_left -= delta
		_on_ground_time_left = clamp(_on_ground_time_left, 0, _on_ground_time_frame)


func _do_player_movement(controls_mappings: Dictionary, delta: float) -> void:
	"""
	Does all player movement depending on their inputs.
	"""
	
	_do_horizontal_movement(controls_mappings, delta)
	_do_jumping(controls_mappings, delta)


func _do_horizontal_movement(controls_mappings: Dictionary, delta) -> void:
	"""
	Sets the horizontal movement for the player depending
	on their inputs.
	"""
	
	var right_strength: float = Input.get_action_strength(controls_mappings["right"])
	var left_strength: float = Input.get_action_strength(controls_mappings["left"])
	var old_x_input = _x_input
	
	_x_input = right_strength - left_strength
	
	var _old_facing_direction: int = _facing_direction
	
	if _x_input > 0:
		_facing_direction = FacingDirection.RIGHT
	elif _x_input < 0:
		_facing_direction = FacingDirection.LEFT
	
	if old_x_input != _x_input and not _local:
		server.send_change_x_input(_x_input)
	
	if _old_facing_direction != _facing_direction and not _local:
		server.send_change_facing_direction(_facing_direction)
	
	_velocity.x += _x_input * _PLAYER_ACCELERATION * delta
	_velocity.x *= pow(_PLAYER_DAMP, delta * 10.0)


func _do_jumping(controls_mappings: Dictionary, delta: float) -> void:
	"""
	Sets the jumping movement for the player depending 
	on their inputs.
	"""
	
	if Input.is_action_just_pressed(controls_mappings["jump"]):
		_jump_time_left = _jump_time_frame
	elif _jump_time_left > 0:
		_jump_time_left -= delta
		_jump_time_left = clamp(_jump_time_left, 0, _jump_time_frame)
	
	if _jump_time_left > 0:
		# Player is jumping off of the ground.
		if _on_ground_time_left > 0:
			_jumps_left = _max_jumps
		
		if _jumps_left > 0 or is_on_wall():
			if not is_on_wall():
				_jumps_left -= 1
			
			_velocity.y = -_jump_force
			_jump_time_left = 0
		


func _do_dashing(controls_mappings: Dictionary, delta: float) -> void:
	"""
	Does dashing for the player depending on their inputs.
	"""
	
	if _dash_timer > 0:
		_dash_timer -= delta
	
	if _dash_timer <= 0 and _x_input != 0:
		if Input.is_action_just_pressed(controls_mappings["dash"]):
			_dash_timer = _dash_cooldown
			
			if _x_input > 0:
				_dash_direction = Vector2(1, 0)
			else:
				_dash_direction = Vector2(-1, 0)
			
			if _dashes > 0:
				_dashes -= 1
				_velocity = _dash_direction * _dash_force
				
				$DashParticles.emitting = true


func _do_wall_slide() -> void:
	"""
	If the player is on the wall, does a wall slide.
	"""
	
	if is_on_wall() and _velocity.y > _wall_slide_speed:
		_velocity.y = _wall_slide_speed


func _move_player() -> void:
	"""
	Moves the player depending on their velocity.
	"""
	
	move_and_slide(_velocity, Vector2(0, -1))
	
	if not _local:
		server.send_player_movement(position.x, position.y)


func _do_shooting(controls_mappings: Dictionary, delta: float) -> void:
	"""
	Makes the player shoot depending on their inputs.
	"""
	
	if Input.is_action_pressed(controls_mappings["shoot"]):
		var _control_scheme: int = _get_controls_type()

		var direction: Vector2
		
		# Control scheme 0 is keyboard layout.
		if _control_scheme == 0:
			direction = get_position().direction_to(get_global_mouse_position())
		else:
			direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3)).normalized()
			
		var bullet_angle := atan2(direction.y, direction.x)
		
		_shoot_direction = Vector2(cos(bullet_angle), sin(bullet_angle))
		$Gun/BulletExit.position = _shoot_direction * _bullet_exit_radius + self.position
		
		_time_left_till_next_bullet -= delta
		
		if _time_left_till_next_bullet <= 0:
			var bullet = _bullet_template.instance()
			
			bullet.set_direction(_shoot_direction)
			bullet.position = $Gun/BulletExit.position
			bullet.scale *= _bullet_scale
			bullet._player_owner = self
			
			get_tree().get_root().get_node("Bullets").add_child(bullet)
			
			_time_left_till_next_bullet = _fire_rate
			
			#server.send_bullet_shot()


func _move_camera() -> void:
	if _root_player and not _local:
		for player in get_parent().get_children():
			$Camera.current = player == self


func on_hit(damage: float) -> void:
	if _shield > 0:
		_shield -= damage
	elif _health > 0:
		_health -= damage
	else:
		death()


func death() -> void:
	#RESPAWN
	_shield = _MAX_SHIELD
	_health = _MAX_HEALTH
	
	add_death()


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
	
	$NameContainer/PlayerName.text = username


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


func is_root_player() -> bool:
	"""
	Returns true if this player is the root player.
	"""
	
	return _root_player


func set_root_player(root_player: bool) -> void:
	"""
	Sets whether or not this player is the root player.
	"""
	
	_root_player = root_player


func set_local(local: bool) -> void:
	"""
	Sets whether or not this player is a local player
	"""
	_local = local


func get_team() -> int:
	"""
	Returns the team the player is on.
	"""
	
	return _team


func set_team(team: int) -> void:
	"""
	Sets the team of the player.
	"""
	
	_team = team


func get_character_id() -> int:
	"""
	Returns the id of the character that the player is playing.
	"""
	
	return _character_id


func set_character_id(character_id: int) -> void:
	"""
	Sets the character id of the player.
	"""
	
	_character_id = character_id


func get_facing_direction() -> int:
	"""
	Returns the facing direction of the player.
	"""
	
	return _facing_direction


func set_facing_direction(facing_direction: int) -> void:
	"""
	Sets the facing direction of the player.
	"""
	
	_facing_direction = facing_direction
	
	$Hitbox/AnimatedSprite.flip_h = _facing_direction == FacingDirection.RIGHT


func get_player_state() -> int:
	"""
	Gets the player state.
	"""
	
	return _player_state


func set_player_state(player_state: int) -> void:
	"""
	Sets the player state.
	"""
	
	_player_state = player_state


func get_x_input() -> float:
	"""
	Returns the x input of the player.
	"""
	
	return _x_input


func set_x_input(x_input: float) -> void:
	"""
	Sets the x input of the player.
	"""
	
	_x_input = x_input


func get_kills() -> int:
	"""
	Returns the amount of kills this player has.
	"""
	
	return _kills


func add_kill() -> void:
	"""
	Adds a kill to the player's kill count.
	"""
	
	_kills += 1


func get_deaths() -> int:
	"""
	Returns the amount of deaths this player has.
	"""
	
	return _deaths


func add_death() -> void:
	"""
	Adds a death to the player's death count.
	"""
	
	_deaths += 1
