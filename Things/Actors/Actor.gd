extends Thing
class_name Actor
tool
# Actors encompass any Thing that acts on its own, hence the name.
# Could also be called Mobs or Pawns

enum {MOVE_OK, MOVE_DIFFERENT_MAP, MOVE_FAIL_GENERIC, MOVE_INVALID_CELL, MOVE_OBSTRUCTED, MOVE_TILES_UNCONNECTED}

var actions: Array = [] setget ,get_actions

var astar: AStar = CustomAStar.new() # Navigation mesh for this Actor. "Let us meet again As Stars"

var sight_radius: float = 5.0

var has_fine_manipulation: bool = true

class CustomAStar:
	extends AStar
	var ready: bool = false
	var actor: Actor = null

	func refresh() -> void:
		clear()
		ready = false
		var map = actor.get("map")
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
				var p_pos: Vector3 = map_astar.get_point_position(p_id)
				var x_pos: Vector3 = map_astar.get_point_position(x_id)
				if x_pos.z > p_pos.z or x_pos.z < p_pos.z:
					continue # Don't make connections between Z-levels. TODO: Add check for stairs/ladders/slopes and flight
				connect_points(p_id,x_id,false)
		ready = true
		for a in (actor as Actor).get_actions():
			a.think()
	
	func test_path_to(destination: Cell) -> bool:
		return actor.astar.get_point_path(actor.cell.point_id,destination.point_id).size() != 0

func _init().():
	type = "Actor"
	character = "A"
	layer = LAYER.ACTOR
	astar.actor = self
	select_priority = 2

func _ready():
	if Engine.editor_hint:
		return
	ai_init()

func tool_lclick_oncell(cell: Cell, event: InputEvent) -> void:
	.tool_lclick_oncell(cell, event)
	if can_exist_on(cell):
		cell.add_thing(copy())

func add_child(node: Node, legible_unique_name: bool = false) -> void:
	if node.get_node_or_null(".."):
		node.get_node("..").remove_child(node)
	if node is Thing:
		node.set_meta("initial_visibility",(node as CanvasItem).visible)
		(node as CanvasItem).visible = false
	.add_child(node, legible_unique_name)

func remove_child(node: Node) -> void:
	if node is Thing:
		(node as CanvasItem).visible = node.get_meta("initial_visibility")
		node.set_meta("initial_visibility",null)

func is_cell_impassable(cell: Cell) -> bool:
	for thing in cell.contents:
		if not (thing is Thing):
			continue
		if thing == self:
			continue
		if thing is Structure:
			if thing is Furniture:
				continue
			if (thing as Structure).construction_state >= Structure.CONSTRUCTION_STAGES.WIP:
				continue
		if thing is Door: # This behavior is defined here in Actor.gd and not in Door.gd so Actor subtypes can override it
			if thing.get("requires_fine_manipulation") and not has_fine_manipulation:
				return true
			if thing.has_meta("Forbidden") and thing.get_meta("Forbidden"):
				return true # TODO: add check for if this actor listens to forbid designations
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
		if not get_path().get_name(2) == "DebugContainer":
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

func find_adjacent_spot(to: Cell) -> Cell: # If the Actor needs to path to a cell adjacent to a (probably impassable) cell, it can find it with this
	var adjacent_cells = to.get_adjacent_cells(Cell.EIGHT)
	if get_parent_cell() in adjacent_cells:
		return get_parent_cell() # We're already adjacent to the destination
	for i in adjacent_cells.size(): # remove impassable cells from adjacent_cells
		var v = adjacent_cells[i]
		if is_cell_impassable(v):
			adjacent_cells[i] = null
	while null in adjacent_cells: # clear up any nulls created by the removal of impassable cells
		adjacent_cells.erase(null)
	if adjacent_cells.empty():
		return null # whoops, all the cells are impassable I guess, nevermind
	var closest: Cell = null
	var lowest_distance: float = INF
	var parent_cell_id = get_parent_cell().point_id
	for cell in adjacent_cells:
		var path: PoolIntArray = astar.get_id_path(parent_cell_id,cell.point_id)
		if path.empty():
			continue
		if path.size() < lowest_distance:
			closest = cell
			lowest_distance = path.size()
	return closest

func on_cell_changed(cell: Cell):
	if cell.point_id > astar.get_point_count():
		return
	var cell_impassability: bool = is_cell_impassable(cell)
	var point_disabability: bool = astar.is_point_disabled(cell.point_id)
	astar.set_point_disabled(cell.point_id,cell_impassability)
	if point_disabability != cell_impassability:
		for a in get_actions():
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
	ai_process()
	.on_turn()
	for action in get_actions():
		if action.allowed_execute:
			action.process()
			break
	if self in get_node("/root/Game/Player").get_selection():
		get_node("/root/Game/Player/Camera2D/UI/SelectionCard/Needs").refresh()

func rawget_actions() -> Array:
	return actions

func get_actions() -> Array:
	var array = []
	for action in actions:
		if action.get_ref():
			array.append(action.get_ref())
	return array

func get_current_action():
	if get_actions().empty():
		return null
	for action in get_actions():
		if action.status >= Actions.STATUS.DONE:
			continue
		if action.allowed_execute:
			return action
	return null

func act(action: String, target=null, force:bool=false, driver=null):
	var new_action = (load("res://Actions.gd") as GDScript)[action].new(self,0,force)
	if target != null:
		new_action.target = target
	if driver != null:
		new_action.driver = driver
	if is_inside_tree():
		if get_node_or_null("/root/Game/Player") and self in $"/root/Game/Player".get("selection"):
			$"/root/Game/Player".call("update_selection_card")
	return new_action

func doing_action(action: String, target=null, driver=null) -> bool:
	for existing_action in get_actions():
		if existing_action.type == action and existing_action.target == target and existing_action.driver == driver:
			return true
		if existing_action.forced:
			return true
	return false

func do_action(action: String, target=null, driver=null):
	if not doing_action(action,target,driver):
		return act(action, target, false, driver)

# AI-related start
# see AI/AI DOCUMENTATION.txt for documentation on some AI and action-related things

enum PRIORITY {IDLE=0,WANT=5,WORK=25,NEED=75,CRITICAL=100}
var needs: Array = []
var needs_dict: Dictionary = {}
var drives: Array = []

func drives_sorter(a: Object,b: Object) -> bool:
	return a.get("priority") > b.get("priority")

func add_drive(new_drive_name: String,priority = null,unique: bool = false) -> void:
	var new_drive: Reference = load("res://AI/Drives/%s.gd" % new_drive_name).new()
	if unique:
		for other_drive in drives:
			# warning-ignore:unsafe_property_access
			if other_drive.type == new_drive_name.to_lower(): # We've found a drive of the same type
				if priority: # update its priority with the one this is being called with
					other_drive.priority = priority
				return # there can only be one, so return
	# warning-ignore:unsafe_property_access
	new_drive.actor = self
	if priority:
		# warning-ignore:unsafe_property_access
		new_drive.priority = priority
	drives.append(new_drive)

func remove_drive(drive_name: String) -> void:
	drive_name = drive_name.to_lower()
	for i in drives.size():
		if drives[i].type == drive_name:
			drives.remove(i)
			break

func ai_init():
	var inherent_needs = needs.duplicate()
	needs.clear()
	for need_to_add in inherent_needs:
		# need_to_add can be a script or a string referring to an inner class in AI/Needs.gd
		var new_need = (load("res://AI/Needs.gd").get(need_to_add) if not need_to_add is Script else need_to_add).new()
		new_need.actor = self
		# warning-ignore:unsafe_cast
		needs_dict[(need_to_add as String) if need_to_add is String else new_need.type] = new_need
		needs.append(new_need)
	var inherent_drives = drives.duplicate()
	drives.clear()
	for drive_to_add in inherent_drives:
		add_drive(drive_to_add)

func ai_process():
	for need in needs:
		for type in ["life","ai"]:
			var funcname = "on_%s_process_%s" % [type,need.type]
			if has_method(funcname): # This allows Actor classes to override how specific needs are processed
				call(funcname,need) # Need is passed so that override can also invoke normal behavior
			else:
				need.call("on_%s_process" % type)
	drives.sort_custom(self,"drives_sorter")
	if not drives.empty():
		for drive in drives:
			var result = drive.act()
			if result == 0:
				break
