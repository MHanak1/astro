class_name Bullet extends Area3D

@export var max_age = 10.0

var player: Player;
var age = 0
var velocity = Vector2()

func _physics_process(delta: float) -> void:
	age += delta
	if age > max_age:
		self.queue_free()
	position += Vector3(velocity.x, 0, velocity.y) * delta
