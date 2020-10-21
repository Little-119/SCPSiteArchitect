extends Thing
class_name Structure

func _init().():
	type = "Structure"
	layer = LAYER.STRUCTURE

func tool_lclick_oncell(cell: Cell) -> void:
	.tool_lclick_oncell(cell)
	var valid: bool = true
	for other_thing in cell.contents:
		if not can_coexist_with(other_thing):
			valid = false
			break
	if valid:
		cell.add_thing(get_script())
