class_name Bullet extends Area3D

@export var max_age = 10.0
@export var damage = 1

var player: Player;
var age = 0
var velocity = Vector2()

func _enter_tree() -> void:
	self.body_entered.connect(on_body_hit)
	
func on_body_hit(body: Node3D):
	if body == self.player:
		return
	if body.has_method("on_bullet_hit"):
		body.on_bullet_hit(self)
	self.queue_free()

func _physics_process(delta: float) -> void:
	age += delta
	if age > max_age:
		self.queue_free()
	position += Vector3(velocity.x, 0, velocity.y) * delta
