class_name PlayerManager extends Node

@export var spawn_positions: Array[Node3D]

static var players: Array[int];
static var current_player = 0
static var authorities = {}

static var instance;

func _init() -> void:
	instance = self
	#create_player(current_player)

func _enter_tree() -> void:
	print("entered tree")
	for player_id in players:
		var player = Player.create(player_id)
		self.add_child(player)
		player.position = self.spawn_positions[player.player_id % spawn_positions.size()].position

func _process(_delta: float) -> void:
	for player_id in players:
		if get_player(player_id) == null:
			print("spawning player: ", player_id)
			var player = Player.create(player_id)
			self.add_child(player)
			player.position = self.spawn_positions[player.player_id % spawn_positions.size()].position
	
		if authorities.has(player_id):	
			PlayerManager.get_player(player_id).set_multiplayer_authority(authorities.get(player_id))

	for child in get_children():
		if child is Player:
			if !players.has(child.player_id):
				print("removing player from node tree: ", child.player_id)
				child.queue_free()
	
	#if get_player(current_player) != null:
	#	Game.set_camera(get_player(current_player).camera())


static func get_player(player_id: int) -> Player:
	if instance != null:
		return instance.get_node("Player %d" % player_id)
	else:
		return null

@rpc("authority", "call_local", "reliable")
static func new_player() -> int:
	var player_id = players.size()
	create_player(player_id)
	return player_id
	
@rpc("authority", "call_local", "reliable")
static func create_player(player_id: int) -> Player:
	print("create_player ", player_id)
	if !players.has(player_id):
		players.append(player_id)
	if instance != null:
		return get_player(player_id)
	else:
		return null
		#players[player_id] = Player.create(player_id)

static func reset_player(player_id: int):
	get_player(player_id).replace_by(Player.create(player_id))

static func delete_player(player_id: int):
	players.erase(player_id)

static func make_current(player_id):
	current_player = player_id
	
static func set_authority(player_id: int, authority: int):
	print("setting authority for ", player_id, ": ", authority)
	authorities.set(player_id, authority)
