extends Node3D

static var camera_locked = false
static var camera: Camera3D

#func _process(delta: float):
#	if $Map != null:
#		$Map.replace_by(current_scene)

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
		
		# if the player is not initialised, the player has not yet been killed. this is to prevent the lobby from continuing while players load
		if player == null:
			count += 1
		elif player.alive:
			count += 1
	return count


func next_scene():
	if is_multiplayer_authority():
		change_scene.rpc("res://scenes/game/lobby.tscn")

	
@rpc("call_local", "reliable")
func change_scene(path):
	get_tree().change_scene_to_file(path)


@rpc("call_local", "reliable")
static func lock_camera(new_camera: Camera3D):
	camera_locked = true
	if camera != null:
		camera.current = false
	camera = new_camera
	camera.make_current()

@rpc("call_local", "reliable")
static func set_camera(camera: Camera3D):
	if !camera_locked:
		if camera != null:
			camera.current = false
		camera  = camera
		camera.make_current()
	

@rpc("call_local", "reliable")
static func unlock_camera():
	print("unlock_camera")
	camera_locked = false
	if !player() == null:
		if camera != null:
			camera.current = false
		camera = player().camera()
		camera.make_current()
