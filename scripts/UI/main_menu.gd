extends Node

const PORT = 46792
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

var peer = ENetMultiplayerPeer.new()
@export var game_scene: PackedScene

func _on_join_game_pressed(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	print(multiplayer.get_peers())
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_host_game_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	print("hiiii")
	
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _add_player(id = 0):
	print(id)
	PlayerManager.create_player(id)
