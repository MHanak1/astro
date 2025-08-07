class_name Player extends CharacterBody3D

const bullet_scene = preload("res://actors/bullet.tscn")

@export var resistance = 1.0
@export var rot_resistance = 30.0
@export var speed = 50.0
@export var strafe_speed = 15.0
@export var bullet_speed = 30.0
@export var min_sync_interval = 0.1
@export var max_sync_interval = 5.0

var player_id = 0;

var positional_data_dirty = false
var last_synced = -100.0

var facing_towards = Vector2(0, 0)
var move_vector = Vector2()
var rotation_delta = 0
var angular_velocity = 0.0

var age = 0.0

var health = Settings.max_player_health()
var last_hit = age
var alive = true


static func create(player_id) -> Player:
	var new = load("res://actors/player.tscn").instantiate() # if preloaded the player doesn't render correctly in compatibility
	new.player_id = player_id
	#new.set_multiplayer_authority(player_id)
	new.name = "Player %d" % player_id
	return new


func _process(delta: float) -> void:
	age += delta
	
	if $Follow:
		$Follow.position = position
	
	if (self.invincible() && (fmod(self.age, 0.3) > 0.15)) || !alive:
		$PlayerMesh.visible = false
	else:
		$PlayerMesh.visible = true

	if !alive:
		return
	

	if multiplayer.peer_connected && is_multiplayer_authority():
		var input = GlobalInput.get_player_input(player_id)
		
		var facing
		
		if input._facing_screen_space && get_viewport().get_camera_3d() != null:
			facing = input._facing - get_viewport().get_camera_3d().unproject_position(self.global_position)
			facing = facing.normalized()
		else:
			facing = input.facing()

		if (facing - facing_towards).length_squared() >  GlobalInput.deadzone * GlobalInput.deadzone:
			if facing.length_squared() <  GlobalInput.deadzone *  GlobalInput.deadzone:
				facing = Vector2()
			self.facing_towards = facing
			self.positional_data_dirty = true

		
		if input.movement().length_squared() > GlobalInput.deadzone * GlobalInput.deadzone:
			move_vector = Vector2(-input.movement().x, input.movement().y)
			if move_vector.length() > 0:
				positional_data_dirty = true
		elif move_vector != Vector2():
			move_vector = Vector2()
			self.positional_data_dirty = true

		if ((age - last_synced) > min_sync_interval && positional_data_dirty) || age - last_synced > max_sync_interval:
			update_positional_data.rpc(position, velocity, facing_towards, move_vector)
			last_synced = age
			self.positional_data_dirty = false
		
		if input.primary:
			if age - last_shot > 0.2:
				self.shoot.rpc()
		

func _physics_process(delta):
	if !alive:
		return
	
	if facing_towards != Vector2():
		rotation_delta = self.facing_towards.angle_to(self.facing_vec()) - angular_velocity * 0.15
	else:
		rotation_delta = - angular_velocity * 1 / rot_resistance
	angular_velocity += rotation_delta

	var _move_vector = move_vector
	_move_vector.x *= strafe_speed
	_move_vector.y *= speed
	_move_vector = _move_vector.rotated(-self.facing_vec().angle_to(Vector2(0, 1)))
	velocity.x += _move_vector.x * delta
	velocity.z += _move_vector.y  * delta

	update_particle_emmiters()

	rotation.y += angular_velocity * delta

	velocity *= (1 - resistance * delta)
	
	move_and_slide()

func update_particle_emmiters():
	var thrusters: Node3D = self.get_node("Thrusters")

	var main_thruster: GPUParticles3D = thrusters.get_node("Main")
	var right_forward_thruster: GPUParticles3D = thrusters.get_node("RightForward")
	var left_forward_thruster: GPUParticles3D = thrusters.get_node("LeftForward")
	var right_backward_thruster: GPUParticles3D = thrusters.get_node("RightBackward")
	var left_backward_thruster: GPUParticles3D = thrusters.get_node("LeftBackward")
	
	main_thruster.emitting = false
	right_forward_thruster.emitting = false
	left_forward_thruster.emitting = false
	right_backward_thruster.emitting = false
	left_backward_thruster.emitting = false
	
	if !alive:
		return
	
	if rotation_delta > 0.1:
		right_backward_thruster.emitting = true
		left_forward_thruster.emitting = true
	elif rotation_delta < -0.1:
		right_forward_thruster.emitting = true
		left_backward_thruster.emitting = true

	if move_vector.y > 0.1:
		main_thruster.emitting = true
	elif move_vector.y < -0.1:
		right_forward_thruster.emitting = true
		left_forward_thruster.emitting = true

@rpc("authority", "call_local", "reliable")
func damage(amount):
	if alive:
		health -= amount
		self.last_hit = age
		if health <= 0:
			self.kill()
		else:
			$Sound/Hit.pitch_scale = randf_range(0.9, 1.1)
			$Sound/Hit.play()
		return health
		
func kill():
	$Sound/Explosion.pitch_scale = randf_range(0.9, 1.1)
	$Sound/Explosion.play()
	Game.on_player_death.emit(self)
	alive = false
	visible = false
	collision_layer = 0
	collision_mask = 0
	
func invincible():
	return self.age - self.last_hit < Settings.invincibility_time()

func on_bullet_hit(bullet: Bullet):
	if is_multiplayer_authority() && !invincible():
		damage.rpc(bullet.damage)

var last_shot = 0.0
@rpc("authority", "call_local", "reliable")
func shoot():
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.velocity = Vector3(self.facing_vec().x * bullet_speed, 0, self.facing_vec().y * bullet_speed) + self.velocity
	bullet.player = self
	bullet.position.x = self.position.x + self.facing_vec().x
	bullet.position.z = self.position.z + self.facing_vec().y
	bullet.rotation = self.rotation
	self.add_child(bullet)
	last_shot = age
	
	$Sound/Shoot.pitch_scale = randf_range(0.9, 1.1)
	$Sound/Shoot.play()
	
	
func facing_vec() -> Vector2:
	return Vector2.from_angle(-rotation.y - PI/2)
	
func camera() -> Camera3D:
	return $Follow/Camera

#network sync
@rpc("authority", "call_remote", "unreliable_ordered")
func update_positional_data(position: Vector3, velocity: Vector3, facing_towards: Vector2, move_vector: Vector2):
	self.position = position
	self.velocity = velocity
	self.facing_towards = facing_towards
	self.move_vector = move_vector
	self.positional_data_dirty = false
