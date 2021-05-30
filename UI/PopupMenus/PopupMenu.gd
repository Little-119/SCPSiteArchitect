extends Panel

func _enter_tree():
	for sibling in get_parent().get_children():
		if sibling == self:
			continue
		if sibling.has_meta("hidden_by_menu"):
			continue
		sibling.set_meta("hidden_by_menu",sibling.visible)
		sibling.visible = false

func _exit_tree():
	var siblings = get_parent().get_children()
	for sibling in siblings:
		if sibling == self:
			continue
		if sibling.name.ends_with("Menu"):
			return
	# warning-ignore:unsafe_method_access
	$"/root/Game".set_paused(false)
	for sibling in siblings:
		if sibling == self:
			continue
		if sibling.has_meta("hidden_by_menu"):
			sibling.visible = sibling.get_meta("hidden_by_menu")
			sibling.remove_meta("hidden_by_menu")

func _input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			if (event as InputEventKey).scancode == KEY_ESCAPE:
				queue_free()
