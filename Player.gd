extends Node

const zoom_min: float = .5
const zoom_max: float = 5.0
const zoom_increment: float = .25
const move_speed: float = 200.0
signal camera_moved

var mousetool = null

var selection = null setget set_selection

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var z_delta: float
		match (event as InputEventMouseButton).button_index:
			BUTTON_LEFT:
				set_selection(null)
			BUTTON_RIGHT:
				if mousetool:
					mousetool = null
					return
			BUTTON_WHEEL_UP:
				z_delta = -zoom_increment
			BUTTON_WHEEL_DOWN:
				z_delta = zoom_increment
		if z_delta != 0:
			emit_signal("camera_moved")
			var new_z = clamp(($"Camera2D" as Camera2D).zoom.x + z_delta,zoom_min,zoom_max)
			($"Camera2D" as Camera2D).zoom = Vector2(new_z,new_z)
			($"Camera2D" as Camera2D).scale = Vector2(new_z,new_z)
	if event is InputEventKey and event.is_pressed():
		match (event as InputEventKey).scancode:
			KEY_SPACE:
				$"/root/Game".set_process(not $"/root/Game".is_processing())
			KEY_ESCAPE:
				if mousetool:
					mousetool = null
				else:
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
		var lowers = Vector2.ZERO
		# warning-ignore:unsafe_property_access
		var uppers: Vector2 = $"/root/Game".current_map.get_pixel_size()
		($"Camera2D" as Camera2D).position = Vector2(clamp(new_pos.x,lowers.x,uppers.x),clamp(new_pos.y,lowers.y,uppers.y))
		($"Camera2D" as Camera2D).force_update_scroll() # ensures UI is properly attached to camera, otherwise it lags behind when moving
		emit_signal("camera_moved")

func _ready() -> void:
	($"Camera2D" as Camera2D).make_current()

func equip_tool(t) -> void:
	mousetool = t

func set_selection(new_selection = null) -> void:
	if selection or new_selection == null:
		var card = get_node_or_null("Camera2D/UI/SelectionCard")
		if card:
			card.queue_free()
	if new_selection:
		var selection_card: Panel = (load("res://SelectionCard.tscn") as PackedScene).instance()
		(selection_card.get_node("RichTextLabel") as RichTextLabel).text = new_selection.get_display_name()
		($"/root/Player/Camera2D/UI" as Control).add_child(selection_card)
	selection = new_selection
