extends Thing
class_name Actor

enum  {MOVE_OK, MOVE_DIFFERENT_MAP, MOVE_FAIL_GENERIC, MOVE_INVALID_CELL, MOVE_OBSTRUCTED, MOVE_TILES_UNCONNECTED}

var actions := []

var astar := CustomAStar.new() # Navigation mesh for this Actor. Let us meet again as stars

class CustomAStar:
	extends AStar
	var ready: bool = false
	var actor: Thing = null
	func get_point_path(from_id: int, to_id: int) -> PoolVector3Array:
		var r = .get_point_path(from_id,to_id)
		print(r)
		return r
	
	func refresh() -> void:
		clear()
		ready = false
		var map = actor.get_map()
		var map_astar: AStar = map.astar
		reserve_space(map_astar.get_point_count())
		for point_id in map_astar.get_points():
			var point_pos: Vector3 = map_astar.get_point_position(point_id)
			var point_cell = map.get_cell(point_pos)
			var weight_scale: float = map_astar.get_point_weight_scale(point_id)
			var impassable: bool = actor.is_cell_impassable(point_cell)
			add_point(point_id,point_pos,weight_scale)
			set_point_disabled(point_id,impassable)
		for point_id in get_points():
			for connected_id in map_astar.get_point_connections(point_id):
				connect_points(point_id,connected_id)
		ready = true
		for a in actor.actions:
			a.think()

func _init().():
	type = "Actor"
	icon = "A"
	layer = LAYER.ACTOR
	astar.actor = self

func is_cell_impassable(cell: Cell,test=false) -> bool:
	for thing in cell.contents:
		if thing == self:
			continue
		if thing.layer >= LAYER.STRUCTURE:
			return true
	return false

func test_move(cella: Cell,cellb: Cell) -> int: # probably needs optimization
	if cellb.is_default_cell: return MOVE_INVALID_CELL
	if cellb == cella: return MOVE_OK
	
	if is_cell_impassable(cellb):
		return MOVE_OBSTRUCTED
	var cpos_diff: Vector3 = cellb.cell_position - cella.cell_position
	if cellb.map != cella.map:
		return MOVE_DIFFERENT_MAP # TODO?: Later down the line, if destination is on a different map, find a way to get to it somehow? Like RW caravans
	if astar.is_point_disabled(cellb.point_id):
		return MOVE_OBSTRUCTED
	if not astar.are_points_connected(cella.point_id,cellb.point_id,false):
		push_warning("Tested movement between disconnected tiles. Are you using move when you meant to use move_to?")
		return MOVE_TILES_UNCONNECTED
	# TODO: make astar generation account for this diagonal checking
#	if abs(cpos_diff.x) == abs(cpos_diff.y) and abs(cpos_diff.x) == 1: # If we're moving diagonally, test the two adjacent tiles
#		for diff in [Vector3(cpos_diff.x,0,0),Vector3(0,cpos_diff.y,0)]:
#			# warning-ignore:unsafe_method_access
#			var cell = cella.get_adjacent_cell(diff)
#			var test_result: int = test_move(cella,cell)
#			if test_result == MOVE_FAIL_GENERIC or test_result == MOVE_OBSTRUCTED:
#				return test_result
	return MOVE_OK

func move_to(destination: Vector3) -> int:
	var test_result: int = test_move(get_parent_cell(),get_map().get_cell(destination))
	if test_result == MOVE_OK:
		force_move(destination)
	return test_result

func move(direction: Vector3) -> int:
	var new_pos: Vector3 = get_parent_cell().cell_position + direction
	return move_to(new_pos)

func _on_map_added_thing(thing: Thing):
	var thing_cell = thing.get_parent_cell()
	var cell_impassability: bool = is_cell_impassable(thing_cell,true)
	var point_disabability: bool = astar.is_point_disabled(thing_cell.point_id)
	astar.set_point_disabled(thing_cell.point_id,cell_impassability)
	if point_disabability != cell_impassability:
		for a in actions:
			a.think()

func on_turn():
	.on_turn()
	for i in actions.size():
		var action = actions[i]
		if not action:
			actions.remove(i)
			i -= 1
			continue
		action.execute()

func die() -> void:
	queue_free()

# Start AI-related

# End AI-related
