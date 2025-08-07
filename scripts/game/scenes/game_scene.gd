class_name GameScene extends Node3D

var scene_change_timer = Timer.new()
var show_scene_timer = Timer.new()

func _enter_tree() -> void:
	if $Camera3D:
		Game.lock_camera($Camera3D)
	
	show_scene_timer.one_shot = true
	show_scene_timer.wait_time = 0.05
	self.add_child(show_scene_timer)
	show_scene_timer.start()


func _ready():
	self.visible = false
	
	scene_change_timer.one_shot = true
	scene_change_timer.wait_time = 2.5
	self.add_child(scene_change_timer)
	
	show_scene_timer.timeout.connect(show_self)
	Game.on_player_death.connect(on_player_death)
	
	
func show_self():
	self.visible = true

func on_player_death(player):
	if Game.living_player_count() <= 1:
		scene_change_timer.start()
		await scene_change_timer.timeout
		Game.next_scene()
