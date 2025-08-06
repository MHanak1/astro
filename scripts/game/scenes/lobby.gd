extends Node

func _enter_tree() -> void:
	Game.lock_camera($Camera3D)

func _exit_tree() -> void:
	Game.unlock_camera()
