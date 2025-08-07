extends Node

const PORT = 46792
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

@export var lobby: PackedScene



func _ready():
	find_child("PlayLocal").grab_focus()
	multiplayer.connected_to_server.connect(start_game)

	
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit(0)


func _on_join_game_pressed():
	join_server((find_child("AddressInput") as LineEdit).text)

func _on_address_input_text_submitted(address: String) -> void:
	join_server(address)

func join_server(address):
	GameServer.join_game(address)

func _on_host_game_pressed():
	GameServer.create_game()
	start_game()

func _on_play_local_pressed() -> void:
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/game/lobby.tscn")
	Game.change_scene(lobby.resource_path)
