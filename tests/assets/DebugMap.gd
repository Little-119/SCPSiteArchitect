extends Map

var mouse_position: Vector2 = Vector2.ZERO

func get_global_mouse_position() -> Vector2:
	return mouse_position

func get_visibility():
	return true
