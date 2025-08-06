extends Node

func _ready():
	Game.on_player_death.connect(on_player_death)

func on_player_death(player):
	if Game.living_player_count() <= 1:
		$SceneChangeTimer.start()
		await $SceneChangeTimer.timeout
		Game.next_scene()


func _enter_tree() -> void:
	Game.lock_camera($Camera3D)
