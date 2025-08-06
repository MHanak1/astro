extends Node

var camera_locked = false
var camera: Camera3D

func player() -> Player:
	if PlayerManager.players.has(PlayerManager.current_player):
		return PlayerManager.players[PlayerManager.current_player]
	else: 
		return null
		

@rpc("call_local", "reliable")
func change_scene(path):
	get_tree().change_scene_to_file(path)


@rpc("call_local", "reliable")
func lock_camera(camera: Camera3D):
	camera_locked = true
	print("lock_camera")
	if self.camera != null:
		self.camera.current = false
	self.camera  = camera
	self.camera.make_current()

@rpc("call_local", "reliable")
func set_camera(camera: Camera3D):
	print("set_camera")
	if !camera_locked:
		print("camera set")
		if self.camera != null:
			self.camera.current = false
		self.camera  = camera
		self.camera.make_current()
	

@rpc("call_local", "reliable")
func unlock_camera():
	print("unlock_camera")
	camera_locked = false
	if !player() == null:
		if self.camera != null:
			self.camera.current = false
		self.camera = player().camera()
		self.camera.make_current()
