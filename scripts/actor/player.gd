class_name Player extends NetworkSyncCharacterBody3D

@export var resistance = 1.0
@export var speed = 50.0
@export var strafe_speed = 15.0
@export var bullet_speed = 30.0

var player_id: int;

static var bullet_scene = preload("res://prefabs/bullet.tscn")

var rotation_delta = 0

func _init() -> void:
	self.name = "Player {0}".format(self.player_id)

func _process(delta: float) -> void:
	var input = GlobalInput.get_player_input(player_id)
	if input.primary:
		self.shoot()

func _physics_process(delta):
	var input = GlobalInput.get_player_input(player_id)
	
	if input.facing().length() > GlobalInput.deadzone:
		rotation_delta = input.facing().angle_to(self.facing()) - angular_velocity * 0.2
		angular_velocity += rotation_delta * 0.5

	else:
		rotation_delta = 0
	
	if input.movement().length() > GlobalInput.deadzone:
		var move_vector = Vector2(-input.movement().x * strafe_speed, input.movement().y * speed)
		move_vector = move_vector.rotated(-self.facing().angle_to(Vector2(0, 1)))
		velocity.x += move_vector.x * delta
		velocity.z += move_vector.y * delta

		
	update_particle_emmiters()

	
	rotation.y += angular_velocity * delta
	angular_velocity *= (1 - resistance * delta)
	velocity *= (1 - resistance * delta)
	
	move_and_slide()


func update_particle_emmiters():
	var input = GlobalInput.get_player_input(player_id)
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
	
	
	if rotation_delta > 0.1:
		right_backward_thruster.emitting = true
		left_forward_thruster.emitting = true
	elif rotation_delta < -0.1:
		right_forward_thruster.emitting = true
		left_backward_thruster.emitting = true
		
	if input.movement().y > 0.1:
		main_thruster.emitting = true
	elif input.movement().y < -0.1:
		right_forward_thruster.emitting = true
		left_forward_thruster.emitting = true

var last_shot = 0.0
func shoot():
	if age - last_shot > 0.2:
		var bullet: Bullet = bullet_scene.instantiate()
		bullet.velocity = Vector3(self.facing().x * bullet_speed, self.facing().y * bullet_speed, 0) + self.velocity
		bullet.player = self
		bullet.position.x = self.position.x + self.facing().x
		bullet.position.z = self.position.z + self.facing().y
		bullet.rotation = self.rotation
		self.add_child(bullet)
		last_shot = age
	
		
func facing() -> Vector2:
	return Vector2.from_angle(-rotation.y - PI/2)
	
func camera() -> Camera3D:
	return self.get_node("Camera")
