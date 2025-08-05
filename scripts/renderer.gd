extends Node

func _ready() -> void:
	RenderingServer.set_debug_generate_wireframes(true)

func _input(event):
			
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		print(vp.debug_draw)
		vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
