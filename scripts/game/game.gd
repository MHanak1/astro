extends Node3D

static var locked_camera: Camera3D

static var common_camera: Camera3D

signal on_player_death(player: Player)
signal on_player_added(player_id: int)
signal on_player_removed(player_id: int)

signal current_player_changed(new: int)

var maps = [
	"res://scenes/game/map1.tscn",
	"res://scenes/game/map2.tscn",
	"res://scenes/game/map3.tscn",
	]
	
func _enter_tree() -> void:
	common_camera = Camera3D.new()
	common_camera.rotation.x = -PI/2
	common_camera.position = Vector3()
	self.add_child(common_camera)
	
func _process(delta: float) -> void:
	if !GameServer.connected:
		
		var players = PlayerManager.players

		var bounding_box_min
		var bounding_box_max
		
		for player_id in players:
			var player = PlayerManager.get_player(player_id)
			if player:
				var pos = player.position
				if !bounding_box_min:
					bounding_box_min = pos
					bounding_box_max = pos
					
				bounding_box_min = bounding_box_min.min(pos)
				bounding_box_max = bounding_box_max.max(pos)
				bounding_box_min = bounding_box_min.min(pos + player.velocity)
				bounding_box_max = bounding_box_max.max(pos + player.velocity)

		if bounding_box_min:
			var center = (bounding_box_min + bounding_box_max) / 2
			var size = bounding_box_max - bounding_box_min

			var target_pos = center
			target_pos.x = center.x
			target_pos.z = center.z
			
			var screen_size = get_viewport().get_visible_rect().size
			var ratio =  screen_size.x/screen_size.y
			
			#common_camera.position.y *= 1 + off_by
			target_pos.y = max(20, max(size.x / ratio, size.z)) * 0.8
			
			common_camera.position += (target_pos - common_camera.position) * delta 
			
			

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
		
		if player != null && player.alive:
			count += 1
	return count


func next_scene():
	if is_multiplayer_authority():
		change_scene.rpc(maps[randi() % maps.size()])

	
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
		if GameServer.connected:
			camera.make_current()
		else:
			common_camera.make_current()

@rpc("call_local", "reliable")
static func unlock_camera():
	locked_camera = null
	if player() != null:
		set_camera(player().camera())
