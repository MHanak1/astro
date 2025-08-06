extends Node3D

@export var height = 10.0
@export var follow: Node3D

func _process(_delta: float) -> void: 
	self.position.x = follow.position.x
	self.position.z = follow.position.z
	self.position.y = height
