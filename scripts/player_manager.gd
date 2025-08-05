class_name PlayerManager extends Node

static var players: Dictionary = {};
static var player_scene = preload("res://prefabs/player.tscn")

static var current_player = 1

#func _init() -> void:
	#create_player(current_player)

func _process(delta: float) -> void:
	var children = self.get_children()
	
	for player_id in players:
		if !children.has(players[player_id]):
			self.add_child(players[player_id])


static func player_count():
	if players == null:
		return 0
	else:
		return players.size()

@rpc("authority", "call_local", "reliable")
static func new_player() -> int:
	var player_id = randi() % 1000
	while players.has(player_id):
		player_id = randi() % 1000
		
	create_player(player_id)
	return player_id
	
@rpc("authority", "call_local", "reliable")
static func create_player(player_id: int):
	if !players.has(player_id):
		var new_player: Player = player_scene.instantiate()
		new_player.player_id = player_id
		players[player_id] = new_player
		
static func delete_player(player_id: int):
	if players.has(player_id):
		var player: Player = players[players]
		player.queue_free()

static func focus_player(player_id):
	current_player = player_id
	
	var camera: Camera3D = players[player_id].camera()
	camera.make_current()
