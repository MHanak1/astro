class_name HealthBar extends Node

@export var player: Player
var percantage = 0.0
var base_scale;

func _ready() -> void:
	base_scale = $Health.scale.x

func _process(delta: float):
	percantage = player.health as float / Settings.max_player_health() as float
	percantage = clamp(percantage, 0.001, 1.0)
	
	$Health.scale.x = base_scale * percantage
	$Health.position.x = base_scale * -(1.0 - percantage)
