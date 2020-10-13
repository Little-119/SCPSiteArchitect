extends Thing
class_name Actor

enum {MOVE_OK, MOVE_FAIL_GENERIC, MOVE_FAIL_INVALIDCELL, MOVE_FAIL_OBSTRUCTED}

func _init().():
	type = "Actor"
	icon = "A"
	layer = LAYER.ACTOR

func test_move(cella: Cell,cellb: Cell) -> int: # probably needs optimization
	if cellb.is_default_cell: return MOVE_FAIL_INVALIDCELL
	
	for t in cellb.contents:
		if t == self:
			continue
		if t.layer >= LAYER.STRUCTURE:
			return MOVE_FAIL_OBSTRUCTED
	var cpos_diff: Vector3 = cellb.cell_position - cella.cell_position
	if abs(cpos_diff.x) == abs(cpos_diff.y) and abs(cpos_diff.x) == 1: # If we're moving diagonally, test the two adjacent tiles
		for diff in [Vector3(cpos_diff.x,0,0),Vector3(0,cpos_diff.y,0)]:
			# warning-ignore:unsafe_method_access
			var cell = get_map().get_cell(($".." as Cell).cell_position + diff)
			var test_result: int = test_move(cella,cell)
			if test_result == MOVE_FAIL_GENERIC or test_result == MOVE_FAIL_OBSTRUCTED:
				return test_result
	return MOVE_OK

func move(dir: Vector3) -> int:
	var new_pos: Vector3 = get_parent_cell().cell_position + dir
	var test_result: int = test_move($"..",get_map().get_cell(new_pos))
	if test_result:
		return test_result
	else:
		force_move(new_pos)
		return MOVE_OK

func on_turn():
	.on_turn()
	# warning-ignore:return_value_discarded
	move(Vector3(Constants.RNG.randi_range(-1,1),Constants.RNG.randi_range(-1,1),0))

func die() -> void:
	queue_free()
