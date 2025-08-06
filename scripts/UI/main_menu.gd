extends Node

const PORT = 46792
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

@export var lobby: PackedScene

func _ready():
	find_child("PlayLocal").grab_focus()


func _on_join_game_pressed():
	join_server((find_child("AddressInput") as LineEdit).text)

func _on_address_input_text_submitted(address: String) -> void:
	join_server(address)


func join_server(address):
	if await GameServer.join_game(address):
		Game.change_scene(lobby.resource_path)


func _on_host_game_pressed():
	if GameServer.create_game():
		Game.change_scene(lobby.resource_path)


func _on_play_local_pressed() -> void:
		Game.change_scene(lobby.resource_path)
