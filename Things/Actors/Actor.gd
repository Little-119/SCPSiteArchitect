extends Thing
class_name Actor

enum {MOVE_OK, MOVE_DIFFERENT_MAP, MOVE_FAIL_GENERIC, MOVE_INVALID_CELL, MOVE_OBSTRUCTED, MOVE_TILES_UNCONNECTED}

var actions: Array = []

var astar := CustomAStar.new() # Navigation mesh for this Actor. Let us meet again as stars

# warning-ignore:unused_class_variable
var sight_radius: float = 5.0

class CustomAStar:
	extends AStar
	var ready: bool = false
	var actor: Actor = null

	func refresh() -> void:
		clear()
		ready = false
		# warning-ignore:unsafe_property_access
		var map = actor.map
		var map_astar: AStar = map.astar
		if map_astar.get_point_count() > get_point_capacity():
			reserve_space(map_astar.get_point_count())
		for p_id in map_astar.get_points():
			var point_pos: Vector3 = map_astar.get_point_position(p_id)
			var point_cell = map.get_cell(point_pos)
			var weight_scale: float = map_astar.get_point_weight_scale(p_id)
			var impassable: bool = (actor as Actor).is_cell_impassable(point_cell)
			add_point(p_id,point_pos,weight_scale)
			set_point_disabled(p_id,impassable)
		for p_id in get_points():
			for x_id in map_astar.get_point_connections(p_id):
				connect_points(p_id,x_id)
		ready = true
		for a in (actor as Actor).actions:
			a.think()

func _init().():
	type = "Actor"
	icon = "A"
	layer = LAYER.ACTOR
	astar.actor = self
	select_priority = 2

func is_cell_impassable(cell: Cell) -> bool:
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
	#var cpos_diff: Vector3 = cellb.cell_position - cella.cell_position
	if cellb.get("map") != cella.get("map"):
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
	elif test_result == MOVE_OBSTRUCTED:
		astar.refresh()
	return test_result

func move(direction: Vector3) -> int:
	var new_pos: Vector3 = get_parent_cell().cell_position + direction
	return move_to(new_pos)

func _on_map_added_thing(thing: Thing):
	var thing_cell = thing.get_parent_cell()
	var cell_impassability: bool = is_cell_impassable(thing_cell)
	var point_disabability: bool = astar.is_point_disabled(thing_cell.point_id)
	astar.set_point_disabled(thing_cell.point_id,cell_impassability)
	if point_disabability != cell_impassability:
		for a in actions:
			if a:
				a.think()

func die() -> void:
	queue_free()

func on_moved(old_cell: Cell = null) -> void:
	.on_moved(old_cell)
	#in_sight_radius = get_cells_in_radius(child.sight_radius)

enum {RELATION_HOSTILE=-100,RELATION_NEUTRAL=0,RELATION_ALLIED=100}

func get_relation(other_actor: Actor) -> int:
	if other_actor == self:
		return 1000
	return RELATION_NEUTRAL

var cells_in_sight: Array

#func see(): #TODO: make this whole system actually detect things
#	if not get_parent_cell():
#		return
#	var cells_in_sight_radius: Array = get_parent_cell().get_cells_in_radius(sight_radius)
#	cells_in_sight.clear()
#	var our_spatial: Spatial = get_parent_cell().get_node("Spatial")
#	for cell in cells_in_sight_radius:
#		var their_spatial: Spatial = cell.get_node("Spatial")
#		var raycast_result: Dictionary = our_spatial.get_world().direct_space_state.intersect_ray(our_spatial.transform.origin,their_spatial.transform.origin)
#		if raycast_result.empty():
#			cells_in_sight.append(cell)
#	print(cells_in_sight.size())

func _physics_process(_delta):
	pass
	#see()

func on_turn():
	.on_turn()
	var actions_tmp = actions.duplicate() # protects against the actions list being modified
	for i in actions_tmp.size():
		var action = actions_tmp[i]
		if not action:
			continue
		if action.allowed_execute:
			action.execute()
			break

func get_current_action():
	if actions.empty():
		return null
	for action in actions:
		if not action:
			continue
		if action.status >= Actions.STATUS.DONE:
			continue
		if action.allowed_execute:
			return action
	return null

func force_action(action: String, target): # called when player is commanding that this actor do a thing
	var new_action = (load("res://Actions.gd") as GDScript)[action].new(self,true,false)
	if target != null:
		new_action.target = target
	return new_action

# Start AI-related

# End AI-related
