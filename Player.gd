extends Node

const zoom_increment: float = .25
const move_speed: float = 200.0

onready var VPort: Viewport = get_viewport()

var mousetool = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if (event as InputEventMouseButton).button_index == BUTTON_RIGHT:
			if mousetool:
				mousetool = null
				return
		var z: float = ($"Camera2D" as Camera2D).zoom.x
		if (event as InputEventMouseButton).button_index == BUTTON_WHEEL_UP:
			# warning-ignore:unsafe_property_access
			$"/root/Game".current_map.view_zlevel_incr(-1)
		#	z -= zoom_increment
		if (event as InputEventMouseButton).button_index == BUTTON_WHEEL_DOWN:
			# warning-ignore:unsafe_property_access
			$"/root/Game".current_map.view_zlevel_incr(1)
		#	z += zoom_increment
		z = clamp(z,zoom_increment,5)
		($"Camera2D" as Camera2D).zoom = Vector2(z,z)
	if event is InputEventKey and event.is_pressed():
		if (event as InputEventKey).scancode == KEY_ESCAPE:
			get_tree().quit()

func _process(delta: float) -> void:
	var move_dir := Vector2.ZERO
	if Input.is_action_pressed("up"): move_dir += Vector2.UP
	if Input.is_action_pressed("down"): move_dir += Vector2.DOWN
	if Input.is_action_pressed("left"): move_dir += Vector2.LEFT
	if Input.is_action_pressed("right"): move_dir += Vector2.RIGHT
	move_dir *= move_speed
	move_dir *= delta
	($"UI" as Control).rect_position = ($"Camera2D" as Camera2D).position
	var new_pos: Vector2 = ($"Camera2D" as Camera2D).position + move_dir
	var lowers: Vector2 = VPort.size/Vector2(-2,-2)
	# warning-ignore:unsafe_property_access
	var uppers: Vector2 = $"/root/Game".current_map.get_pixel_size() + (VPort.size/-2)
	($"Camera2D" as Camera2D).position = Vector2(clamp(new_pos.x,lowers.x,uppers.x),clamp(new_pos.y,lowers.y,uppers.y))

func _ready() -> void:
	($"Camera2D" as Camera2D).current = true

func equip_tool(t) -> void:
	mousetool = t

func get_mouse_position() -> Vector2:
	var mouse_position: Vector2 = ($"/root" as Viewport).get_mouse_position()
	mouse_position += ($"Camera2D" as Camera2D).position
	return mouse_position
