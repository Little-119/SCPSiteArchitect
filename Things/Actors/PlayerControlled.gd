extends Actor
class_name PlayerControlledActor
# This class is more or less for testing

var dir := Vector2.ZERO

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			KEY_UP, KEY_KP_8: dir = Vector2.UP
			KEY_DOWN, KEY_KP_2: dir = Vector2.DOWN
			KEY_LEFT, KEY_KP_4: dir = Vector2.LEFT
			KEY_RIGHT, KEY_KP_6: dir = Vector2.RIGHT
			KEY_KP_7: dir = Vector2.UP + Vector2.LEFT
			KEY_KP_9: dir = Vector2.UP + Vector2.RIGHT
			KEY_KP_1: dir = Vector2.DOWN + Vector2.LEFT
			KEY_KP_3: dir = Vector2.DOWN + Vector2.RIGHT

func on_turn():
	if dir != Vector2.ZERO:
# warning-ignore:return_value_discarded
		move(Vector3(dir.x,dir.y,0))
	dir = Vector2.ZERO

func splat():
	print("splat")
	die()
