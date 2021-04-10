extends "res://tests/integration/test_map_virtual_game.gd"

class TestWithSelection extends "res://tests/integration/test_map_virtual_game.gd":
	var cell0: Cell
	func before_each():
		.before_each()
		var click_event = InputEventMouseButton.new()
		click_event.pressed = true
		click_event.button_index = 1
		game.current_map.mouse_position = Vector2.ONE * 2.5 * ProjectSettings.get_setting("Game/cell_size")
		cell0 = game.current_map.get_cell(Vector3(2,2,0))
		cell0.add_thing(Actor)
		game.current_map._unhandled_input(click_event)

	func test_selection():
		assert_has(game.get_node("Player").selection,cell0.contents[0])

	func test_force_action():
		if cell0.contents.size() == 0:
			return
		var actor = cell0.contents[0]
		var rclick_event = InputEventMouseButton.new()
		rclick_event.pressed = true
		rclick_event.button_index = 2
		game.current_map.mouse_position = Vector2(3.5,2.5) * ProjectSettings.get_setting("Game/cell_size")
		game.current_map._unhandled_input(rclick_event)
		var action_button = game.get_node_or_null("Player/Camera2D/UI/ActionsCard/MoveTo")
		assert_not_null(action_button)
		if action_button:
			# warning-ignore:unsafe_cast
			(action_button as Button).emit_signal("pressed")
			assert_not_null(actor.actions.front(),"First item in Actor's Actions was null")
			# warning-ignore:unsafe_property_access
			# warning-ignore:unsafe_property_access
			assert_eq(actor.actions.front().get_script(),(load("res://Actions.gd") as GDScript).MoveTo,"First item in Actor's Actions was not a MoveTo")
		
