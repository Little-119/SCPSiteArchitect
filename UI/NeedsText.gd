extends RichTextLabel

func refresh():
	var player = get_node("../../../..") #./SelectionCard/UI/Camera2D/Player
	var selection_derefd = player.get_selection()
	var selected = selection_derefd.front()
	if selection_derefd.size() != 1 or not "needs" in selected:
		text = ""
		return
	var needs_text: String = ""
	var longest_type: String = ""
	for need in selected.needs:
		if need.type.length() > longest_type.length():
			longest_type = need.display_name
	for need in selected.needs:
		var prefix = "%" + str(longest_type.length()) + "s"
		prefix = prefix % need.display_name + ": "
		needs_text += prefix + Globals.generate_ascii_progress_bar(need.get_magnitude() * 100,20 - prefix.length()) + "\n"
	text = needs_text
