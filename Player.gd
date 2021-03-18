extends Node
class_name Player

const zoom_min: float = .5
const zoom_max: float = 5.0
const zoom_increment: float = .25
const move_speed: float = 200.0
signal camera_moved

var mousetool = null

var selection: Array = []# setget set_selection

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var z_delta: float
		match (event as InputEventMouseButton).button_index:
			BUTTON_LEFT,BUTTON_RIGHT:
				var old_actions_panel = get_node_or_null("Camera2D/UI/ActionsCard")
				if old_actions_panel:
					old_actions_panel.visible = false
					old_actions_panel.name += "Freed"
					old_actions_panel.queue_free()
				continue
			BUTTON_LEFT:
				select(null)
				continue
			BUTTON_RIGHT:
				if mousetool:
					set_mousetool(null)
				continue
			BUTTON_LEFT, BUTTON_RIGHT:
				var old_panel = get_node_or_null("Camera2D/UI/ActionsCard")
				if old_panel:
					old_panel.visible = false
					old_panel.name += "Freed"
					old_panel.queue_free()
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
				$"..".set_process(not $"..".is_processing())
			KEY_ESCAPE:
				if mousetool:
					set_mousetool(null)
					get_tree().set_input_as_handled()

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
		var uppers: Vector2 = $"..".get("current_map").get_pixel_size() if get_node_or_null("..") and $"..".get("current_map") else Vector2.ZERO
		($"Camera2D" as Camera2D).position = Vector2(clamp(new_pos.x,lowers.x,uppers.x),clamp(new_pos.y,lowers.y,uppers.y))
		($"Camera2D" as Camera2D).force_update_scroll() # ensures UI is properly attached to camera, otherwise it lags behind when moving
		($"/root/Game/DebugContainer" as Control).rect_position = ($"Camera2D" as Camera2D).position - get_viewport().size/2
		emit_signal("camera_moved")

func _ready() -> void:
	if get_path().get_name(2) != "DebugContainer":
		($"Camera2D" as Camera2D).make_current()

func set_mousetool(new_mousetool) -> void:
	if new_mousetool == null:
		if $"..".get("current_map"):
			$"..".get("current_map").call("update")
	mousetool = new_mousetool

func select(new_selection = null,clear_old_selection: bool = true) -> void:
	var changed = selection.duplicate()
	changed.append(new_selection)
	#if selection.size() > 0 or new_selection == null:
	if true:
		var card = get_node_or_null("Camera2D/UI/SelectionCard")
		if card:
			card.name = "SelectionCardFreed"
			card.queue_free()
		if clear_old_selection:
			selection.clear()
	selection.append(new_selection)
	if new_selection:
		var selection_card: Panel = (load("res://SelectionCard.tscn") as PackedScene).instance()
		($"Camera2D/UI" as Control).add_child(selection_card,true)
		update_selection_card()
	for thing in changed:
		if not thing:
			continue
		thing.update()
	if get_node_or_null("..").get("current_map"):
		$"..".get("current_map").call("update")

func update_selection_card() -> void:
	var selection_card: Panel = get_node_or_null("Camera2D/UI/SelectionCard")
	if not selection_card:
		return
	if selection.size() == 1:
		var selected: Thing = selection[0]
		(selection_card.get_node("Title") as RichTextLabel).text = (selected as Thing).get_display_name()
		var action_text: String = ""
		if selected is Actor:
			var current_action: Actions.BaseAction = (selected as Actor).get_current_action()
			if not current_action:
				action_text = "Idle"
			else:
				if current_action.driver:
					action_text = current_action.driver.get_display_name()
				else:
					action_text = current_action.get_display_name()
		(selection_card.get_node("CurrentAction") as RichTextLabel).text = action_text
	elif selection.size() > 1:
		var title_text: String = "Things"
		(selection_card.get_node("Title") as RichTextLabel).text = title_text + " x" + str(selection.size()) # TODO: find if everything selected is of a common type and show that common type here because that's how RW does it so why not actually maybe that's a bad way of thinking
		
