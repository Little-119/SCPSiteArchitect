extends Node

const zoom_min: float = 1.0 # When zoomed below one, the UI jiggles when moving. Why? I don't know. This is fine.
const zoom_max: float = 5.0
const zoom_increment: float = .25
const move_speed: float = 200.0
signal camera_moved

onready var VPort: Viewport = get_viewport()

var mousetool = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if (event as InputEventMouseButton).button_index == BUTTON_RIGHT:
			if mousetool:
				mousetool = null
				return
		var z: float = ($"Camera2D" as Camera2D).zoom.x
		match (event as InputEventMouseButton).button_index:
			BUTTON_WHEEL_UP:
				z -= zoom_increment
			BUTTON_WHEEL_DOWN:
				z += zoom_increment
		if z != 0:
			emit_signal("camera_moved")
			z = clamp(z,zoom_min,zoom_max)
			($"Camera2D" as Camera2D).zoom = Vector2.ONE * z
			($"Camera2D" as Camera2D).scale = Vector2.ONE * z
	if event is InputEventKey and event.is_pressed():
		if (event as InputEventKey).scancode == KEY_ESCAPE:
			get_tree().quit()

func _process(delta: float) -> void:
	var move_dir := Vector2.ZERO
	if Input.is_action_pressed("up"): move_dir += Vector2.UP
	if Input.is_action_pressed("down"): move_dir += Vector2.DOWN
	if Input.is_action_pressed("left"): move_dir += Vector2.LEFT
	if Input.is_action_pressed("right"): move_dir += Vector2.RIGHT
	if move_dir != Vector2.ZERO:
		move_dir *= move_speed
		move_dir *= delta
		var new_pos: Vector2 = ($"Camera2D" as Camera2D).get_camera_position() + move_dir
		var lowers: Vector2 = VPort.size/Vector2(-2,-2)
		# warning-ignore:unsafe_property_access
		var uppers: Vector2 = $"/root/Game".current_map.get_pixel_size() + (VPort.size/-2)
		($"Camera2D" as Camera2D).position = Vector2(clamp(new_pos.x,lowers.x,uppers.x),clamp(new_pos.y,lowers.y,uppers.y))
		($"Camera2D" as Camera2D).force_update_scroll()
		emit_signal("camera_moved")

func _ready() -> void:
	($"Camera2D" as Camera2D).make_current()
	($"Camera2D/UI" as Control).rect_position = ($"/root" as Viewport).size / Vector2(-2,2)

func equip_tool(t) -> void:
	mousetool = t

func get_mouse_position() -> Vector2:
	var mouse_position: Vector2 = ($"/root" as Viewport).get_mouse_position()
	return mouse_position

func get_global_mouse_position() -> Vector2:
	var mouse_position: Vector2 = get_mouse_position()
	mouse_position -= (($"/root" as Viewport).size/2) - ($"Camera2D" as Camera2D).position
	mouse_position *= ($"Camera2D" as Camera2D).zoom.x
	return mouse_position
	
