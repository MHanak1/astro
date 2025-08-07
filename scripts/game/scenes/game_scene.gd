class_name GameScene extends Node

var scene_change_timer = Timer.new()

func _enter_tree() -> void:
	if $Camera3D:
		Game.lock_camera($Camera3D)


func _ready():
	scene_change_timer.one_shot = true
	scene_change_timer.wait_time = 2.5
	self.add_child(scene_change_timer)
	
	Game.on_player_death.connect(on_player_death)

func on_player_death(player):
	if Game.living_player_count() <= 1:
		scene_change_timer.start()
		await scene_change_timer.timeout
		Game.next_scene()
