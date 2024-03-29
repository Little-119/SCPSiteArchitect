extends Button

var designator: Object

func _input(event: InputEvent):
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).is_echo():
		# warning-ignore:unsafe_property_access
		if (designator.action and event.is_action(designator.action)):
			emit_signal("pressed")

func _on_pressed():
	# warning-ignore:unsafe_method_access
	designator.on_activate()
	($"/root/Game/Player" as Player).update_selection_card()
