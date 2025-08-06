extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected

static var connected = false

const PORT = 19523
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

const main_menu = "res://scripts/UI/main_menu.gd"

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	multiplayer.multiplayer_peer = null
	PlayerManager.players.clear()

	if address.is_empty():
		address = DEFAULT_SERVER_IP

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return false
	multiplayer.multiplayer_peer = peer


func create_game():
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return false
	multiplayer.multiplayer_peer = peer

	connected = true
	PlayerManager.players.clear()
	
	var player_id = PlayerManager.current_player
	PlayerManager.create_player(player_id)
	PlayerManager.make_current(player_id)
	PlayerManager.set_authority(player_id, multiplayer.get_unique_id())

	
	return true

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	PlayerManager.players.clear()


# Every peer will call this when they have loaded the game scene.
#@rpc("any_peer", "call_local", "reliable")
#func player_loaded():
#	Game.player().positional_data_dirty = true

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	if multiplayer.is_server():
		var player_id = multiplayer.get_peers().size()
		_on_server_connect.rpc_id(id, player_id)
	_register_player.rpc_id(id, PlayerManager.current_player)
	if Game.player() != null:
		Game.player().positional_data_dirty = true
	print("player connected")
	PlayerManager.set_authority(PlayerManager.new_player(), id)

@rpc("authority", "reliable")
func _on_server_connect(player_id):
	connected = true
	PlayerManager.create_player(player_id)
	PlayerManager.make_current(player_id)
	PlayerManager.set_authority(player_id, multiplayer.get_unique_id())
	
@rpc("any_peer", "call_remote", "reliable")
func _register_player(player_id):
	if PlayerManager.get_player(player_id) == null:
		var peer_id = multiplayer.get_remote_sender_id()
		print(multiplayer.get_unique_id(), ": registering player ", player_id)
		PlayerManager.create_player(player_id)
		PlayerManager.set_authority(player_id, peer_id)
		player_connected.emit(player_id)

func _on_player_disconnected(id):
	# if a player with higher sequence number disconnected, take their spot	
	for player in PlayerManager.authorities:
		if PlayerManager.authorities[player] == id:
			PlayerManager.delete_player(player)

	player_disconnected.emit(id)


func _on_connected_ok():
	#var player_id = multiplayer.get_peers().size()
	#PlayerManager.create_player(player_id)
	#PlayerManager.make_current(player_id)
	player_connected.emit()


func _on_connected_fail():
	print("connection failed")
	connected = false
	multiplayer.multiplayer_peer = null
	
	#get_tree().change_scene_to_file(main_menu)

func _on_server_disconnected():
	print("connection disconnected")
	connected = false
	multiplayer.multiplayer_peer = null
	PlayerManager.players.clear()
	server_disconnected.emit()
	Game.change_scene(main_menu)
