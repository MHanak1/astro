extends Node

func _process(delta: float) -> void:
	if Game.living_player_count() <= 1 && Game.player_count() > 1:
		Game.next_scene()

func _enter_tree() -> void:
	Game.lock_camera($Camera3D)
