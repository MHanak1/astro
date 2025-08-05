extends Node

var inputs = {}

@export var deadzone = 0.05;

var devce_to_player_id = {}
var controller_to_player_id = {}
var controller_separate = false;

class PlayerInput:
	var _movement: Vector2
	var _facing: Vector2
	var primary = false
	var secondary = false
	
	func _init() -> void:
		self._movement = Vector2(0, 0)
		self._facing = Vector2(0, -1)
		
	func movement() -> Vector2:
		if self._movement.length() > 1:
			return self._movement.normalized()
		else:
			return self._movement
	
	func facing() -> Vector2:
		return self._facing.normalized()


func _input(event: InputEvent) -> void:	
	var is_controller = false
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		is_controller = true
	
	var is_multiplayer = false
	
	var player_id = 0
	
	if !is_multiplayer:
		var is_player_0 = false
		var player_id_map: Dictionary
		if is_controller && controller_separate:
			player_id_map = controller_to_player_id
		elif is_controller && event.device > 0:
			player_id_map = controller_to_player_id
			is_player_0 = true
		else:
			if event.device == 0:
				is_player_0 = true
			player_id_map = devce_to_player_id
		
		if !player_id_map.has(event.device):
			if is_player_0:
				PlayerManager.create_player(0)
				player_id_map[event.device] = 0
			else:
				player_id_map[event.device] = PlayerManager.new_player()

		player_id = player_id_map[event.device]
	
	
	var input = get_player_input(player_id)
	
	#mouse
	if event is InputEventMouseMotion:
		input._facing = (event.position - (get_viewport().get_visible_rect().size as Vector2 / 2)).normalized()
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				input.primary = event.is_pressed()
			MOUSE_BUTTON_RIGHT:
				input.secondary = event.is_pressed()

	
	#keyboard
	elif event is InputEventKey:
		match event.keycode:
			KEY_W:
				if event.is_pressed():
					input._movement.y += 1
				else:
					input._movement.y = 0
			KEY_S:
				if event.is_pressed():
					input._movement.y -= 1
				else:
					input._movement.y = 0
			KEY_A:
				if event.is_pressed():
					input._movement.x -= 1
				else:
					input._movement.x = 0
			KEY_D:
				if event.is_pressed():
					input._movement.x += 1
				else:
					input._movement.x = 0
	
	#D-Pad
	elif event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_START:
				if event.is_pressed() && event.device == 0: # only allow the 1st connected controller to trigger this
					self.controller_separate = !self.controller_separate
			JOY_BUTTON_DPAD_UP:
				if event.is_pressed():
					input._movement.y += 1
				else:
					input._movement.y = 0
			JOY_BUTTON_DPAD_DOWN:
				if event.is_pressed():
					input._movement.y -= 1
				else:
					input._movement.y = 0
			JOY_BUTTON_DPAD_LEFT:
				if event.is_pressed():
					input._movement.x -= 1
				else:
					input._movement.x = 0
			JOY_BUTTON_DPAD_RIGHT:
				if event.is_pressed():
					input._movement.x += 1
				else:
					input._movement.x = 0
			JOY_BUTTON_RIGHT_SHOULDER:
				input.primary = event.is_pressed()
			JOY_BUTTON_LEFT_SHOULDER:
				input.primary = event.is_pressed()

	#joystick
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X:
				input._movement.x = event.axis_value
			JOY_AXIS_LEFT_Y:
				input._movement.y = -event.axis_value
			JOY_AXIS_RIGHT_X:
				input._facing.x = event.axis_value
			JOY_AXIS_RIGHT_Y:
				input._facing.y = event.axis_value
	#print(event.device, ", ", input._movement)
	#print(event)
	
	if input._movement.length() < deadzone:
		input._movement = Vector2(0, 0)
	if input._facing.length() < deadzone:
		input._facing = Vector2(0, 0)

func get_player_input(player: int) -> PlayerInput:
	if !inputs.has(player):
		set_player_input(player, PlayerInput.new())
	return inputs[player]
	
	return inputs[player]

func set_player_input(player: int, input: PlayerInput) -> void:
	inputs[player] = input
