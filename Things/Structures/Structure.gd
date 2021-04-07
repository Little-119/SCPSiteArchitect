extends Thing
class_name Structure
# Structures are structures like walls and furniture

func _init().():
	type = "Structure"
	layer = LAYER.STRUCTURE
	select_priority = 1

func tool_lclick_oncell(cell: Cell, event: InputEvent) -> void:
	.tool_lclick_oncell(cell, event)
	var valid: bool = true
	for other_thing in cell.contents:
		if not can_coexist_with(other_thing):
			valid = false
			break
	if valid:
		cell.add_thing(get_script())
