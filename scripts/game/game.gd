extends Node3D

static var locked_camera: Camera3D

signal on_player_death(player: Player)
signal on_player_added(player_id: int)
signal on_player_removed(player_id: int)

signal current_player_changed(new: int)


static func player() -> Player:
	return PlayerManager.get_player(PlayerManager.current_player)

static func player_count():
	if PlayerManager.players == null:
		return 0
	else:
		return PlayerManager.players.size()
		
static func living_player_count() -> int:
	var count = 0
	for player_id in PlayerManager.players:
		var player = PlayerManager.get_player(player_id)
		
		if player == null && player.alive:
			count += 1
	return count


func next_scene():
	if is_multiplayer_authority():
		change_scene.rpc("res://scenes/game/lobby.tscn")

	
@rpc("call_local", "reliable")
func change_scene(path):
	get_tree().change_scene_to_file(path)


@rpc("call_local", "reliable")
static func lock_camera(camera: Camera3D):
	locked_camera = camera
	camera.make_current()

@rpc("call_local", "reliable")
static func set_camera(camera: Camera3D):
	if (!locked_camera || !is_instance_valid(locked_camera)) && camera:
		camera.make_current()
	

@rpc("call_local", "reliable")
static func unlock_camera():
	locked_camera = null
	if player() != null:
		player().camera().make_current()
