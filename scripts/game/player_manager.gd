class_name PlayerManager extends Node

@export var spawn_positions: Array[Node3D]

static var players: Dictionary = {};
static var current_player = 1

#func _init() -> void:
	#create_player(current_player)

func _process(_delta: float) -> void:
	var children = self.get_children()
	
	for player_id in players:
		var player: Player = players[player_id]
		if !children.has(player):
			self.add_child(player)
			player.reset_position()
			player.position = self.spawn_positions[player.nth_player % spawn_positions.size()].position
	
	for child in children:
		if child is Player:
			if !players.has(child.player_id):
				child.queue_free()


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
	print("create_player ", player_id)
	if !players.has(player_id):
		players[player_id] = Player.create(player_id)
		
static func delete_player(player_id: int):
	players.erase(player_id)

static func make_current(player_id):
	current_player = player_id
	Game.set_camera(players[current_player].camera())
