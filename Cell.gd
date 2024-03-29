extends Node2D
class_name Cell
# A cell is a space in which Things often exist. Probably should've been called tiles.
# Cells are arranged in a grid in Maps, as one would expect tiles to be.

export var is_default_cell: bool = false # Whether this is the Default Cell or not.

var map = null # Map that this Cell is part of
var contents: Array = [] # List of Things in the cell. get_children() does the same thing unless Cells ever get non-Thing children
var cell_position := Vector3.ZERO setget set_cell_position # This Cell's position on the grid, not position on the screen

# warning-ignore:unused_class_variable
var point_id: int = 0 # The cell's point ID in the parent map's AStar

func _to_string():
	return "Cell (Pos: %s)" % cell_position

func _init():
	var spatial = Spatial.new()
	spatial.name = "Spatial"
	add_child(spatial)
	z_index -= 1

func _ready():
	name = "Cell %s" % cell_position if not is_default_cell else "DefaultCell"
	#add_thing(ThingsManager.things["Thing"].get_script().new())

func _draw():
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE*ProjectSettings.get_setting("Game/cell_size")),Color(.15,.15,.15))

func set_cell_position(newpos: Vector3 = cell_position) -> void:
	position = Vector2(newpos.x * ProjectSettings.get_setting("Game/cell_size"),newpos.y * ProjectSettings.get_setting("Game/cell_size"))
	($"Spatial" as Spatial).transform.origin = Vector3(newpos.x,newpos.z,newpos.y)
	cell_position = newpos

func get_adjacent_cell(offset: Vector3) -> Cell:
	if not map:
		return null
	return map.get_cell_or_null(Vector3(cell_position.x+offset.x,cell_position.y-offset.y,cell_position.z-offset.z))

func get_cells_in_directions(directions: PoolVector3Array) -> Array:
	var adj_cells: Array = []
	for dir in directions:
		var cell: Cell = get_adjacent_cell(dir)
		if cell:
			adj_cells.append(cell)
	return adj_cells

enum {FOUR=4,SIX=6,EIGHT=8,TEN=10,TWENTYSIX=26} # These are the numbers that can be passed to get_adjacent_cells

func get_adjacent_cells(number: int):
	# keep in mind that these directions are relative to the camera.
	# e.g. Vector3.BACK (0,0,1) is a tile up (away from the ground) in the game world
	var directions: PoolVector3Array = [Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT]
	# all allowed numbers of cells include the adjacent four cells
	match number:
		FOUR:
			pass
		SIX: # adjacent including up and down
			directions.append_array(PoolVector3Array([Vector3.FORWARD,Vector3.BACK]))
		EIGHT, TEN, TWENTYSIX: # adjacent including diagonal on the same Z-Level
			directions.append_array(PoolVector3Array([Vector3.UP+Vector3.LEFT,Vector3.UP+Vector3.RIGHT,Vector3.DOWN+Vector3.LEFT,Vector3.DOWN+Vector3.RIGHT]))
			continue
		EIGHT:
			pass
		TEN: # adjacent including diagonal on the same Z-level plus the two above and below cells
			directions.append_array(PoolVector3Array([Vector3.FORWARD,Vector3.BACK]))
		TWENTYSIX:
			for z in PoolVector3Array([Vector3.FORWARD,Vector3.BACK]):
				var dirs: PoolVector3Array = [Vector3.ZERO,Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.UP+Vector3.LEFT,Vector3.UP+Vector3.RIGHT,Vector3.DOWN+Vector3.LEFT,Vector3.DOWN+Vector3.RIGHT]
				for i in dirs.size():
					dirs[i] += z
				directions += dirs
		_:
			push_error("Invalid number (%s) passed to %s.get_adjacent_cells" % [number,self])
	return get_cells_in_directions(directions)

static func get_vector3s_in_radius(radius: float, multi_z: bool = false) -> PoolVector3Array: # like get_cells_in_radius, but returns an array
	# Returns a sqaure as a band-aid performance fix. TODO: Make it return a circle of cells, but optimized
	var directions: PoolVector3Array = []
	var z_radius = .5 if not multi_z else radius
	for z in (range(-floor(radius),ceil(radius))) if multi_z else [0]:
		for y in range(-floor(radius),ceil(radius)):
			for x in range(-floor(radius),ceil(radius)):
				directions.append(Vector3(x,y,z))
	return directions

func get_positions_in_radius(radius: float, multi_z: bool = false) -> PoolVector3Array:
	var directions: PoolVector3Array = get_vector3s_in_radius(radius, multi_z)
	for i in directions.size():
		directions[i] += cell_position
	return directions

func get_cells_in_radius(radius: float, multi_z: bool = false) -> Array:
	return get_cells_in_directions(get_vector3s_in_radius(radius,multi_z))

func on_left_click(event: InputEventWithModifiers) -> void: # called in Map.gd. Probably could be called here, too bad!
	var thing_to_select
	var selected_at: int = contents.size()
	if map.get_player().get("selection").size() > 0:
		for selected in map.get_player().get("selection"):
			var found_at = contents.find(selected)
			if found_at >= 0 and found_at < selected_at:
				selected_at = found_at
		if selected_at == 0:
			selected_at = contents.size()
	var r = range(0,selected_at,1)
	r.invert()
	for priority in [2,1]:
		for i in r:
			pass
			var thing = contents[i]
			if thing.select_priority == priority:
				thing_to_select = thing
				break
		if thing_to_select:
			break
	if thing_to_select:
		map.get_player().call("select",thing_to_select,not event.shift)
		get_tree().set_input_as_handled()

func on_right_click(event: InputEventWithModifiers) -> void:
	var actions: Array = []
	var actionable_results: Dictionary = {}
	var actions_script: GDScript = load("res://Actions.gd")
	if map.get_player().get("selection").empty():
		return
	for selected in map.get_player().get("selection"):
		if not selected:
			continue
		if selected.get("actions") == null: # check if selected is an Actor
			continue
		var tile_open: bool = true
		var my_actions: Array = []
		for thing in contents:
			if not selected.can_coexist_with(thing):
				tile_open = false
				break
		if tile_open:
			my_actions.append("MoveTo")
		for action_name in my_actions:
			if not action_name in actions:
				actions.append(action_name)
			if actions_script[action_name]:
				var action_node = actions_script[action_name].new(selected,-1)
				var actionable_result = action_node.is_actionable(self)
				# warning-ignore:unsafe_property_access
				if actionable_result.code != actions_script.STATUS.OK:
					actionable_results[action_name] = actionable_result
				action_node.queue_free()
	if actions.empty():
		return
	else:
		get_tree().set_input_as_handled()
		var panel: Panel = (load("res://ActionsCard.tscn") as PackedScene).instance()
		for action in actions:
			if actionable_results.has(action):
				# warning-ignore:unsafe_property_access
				if actionable_results[action].code == actions_script.STATUS.DONE:
					continue
			var button = Button.new()
			button.name = str(action)
			button.text = " " + action if not actionable_results.has(action) else " %s (%s)" % [action,actionable_results[action].details]
			if actionable_results.has(action):
				# warning-ignore:unsafe_property_access
				# warning-ignore:unsafe_property_access
				if actionable_results[action].code == actions_script.STATUS.FAIL or actionable_results[action].code == actions_script.STATUS.ERROR:
					button.disabled = true
			panel.add_child(button,true)
			button.rect_size = Vector2(128,30)
			button.rect_position += Vector2(0,20 * (get_child_count()-1))
			button.align = Button.ALIGN_LEFT
			button.connect("pressed", panel, "queue_free")
			for selected in map.get_player().get("selection"):
				button.connect("pressed", selected, "act", [action,self,true], CONNECT_ONESHOT)
		map.get_player().get_node("Camera2D/UI").add_child(panel,true)
		panel.name = "ActionsCard"

		panel.rect_position = get_global_mouse_position() + (get_viewport().size/2) - (map.get_player().get_node("Camera2D") as Camera2D).position # TODO: I forget how to get the screen position of a cell.

func on_mouseonto() -> void:
	pass

func order_children() -> void: # Re-order this Cell's children in the tree. I forget why this is necessary 
	var children = get_children()
	if children.size() == 0: return
	children.sort_custom(ThingsManager, "sort_for_layering")
	for i in children.size():
		var c = children[i]
		move_child(c,i)

func zlevel_update(zlevel) -> void:
	if is_default_cell or not map:
		return
	if not zlevel is int:
		zlevel = map.current_zlevel
	var diff = cell_position.z - zlevel
	visible = diff <= 0 and diff >= -3
	modulate = Color(1,1,1,clamp(1-(diff/-4),0,1))

func add_child(child: Node,b: bool = false) -> void:
	var old_parent
	if "type" in child: # 'if child is Thing' causes an error. Workaround: see if it has a property called type
		old_parent = child.get_node_or_null("..")
		if old_parent:
			old_parent.remove_child(child)
		contents.append(child)
		order_children()
	.add_child(child,b)
	if "type" in child: # same as above, but this needs to be called after add_child
		child.call("on_moved",old_parent)
	if not old_parent or (map != old_parent.map): # Object isn't being moved from any cell, or the old parent is in a different map
		if old_parent:
			old_parent.map.things.erase(child)
		if child.get("type"):
			map.propagate_call("on_cell_changed",[self])
			map.emit_signal("thing_added",child)
			map.things.append(child)
			if child.get("astar"):
				child.get("astar").refresh()
	elif old_parent: # if the node is moving between cells in the same map
		map.propagate_call("on_cell_changed",[self])
	zlevel_update(null)

func remove_child(child: Node) -> void:
	if child.get("type"):
		contents.erase(child)
	.remove_child(child)
	(map.propagate_call("on_cell_changed",[self]) if map else null) # "if not map: ..." does not work here for some reason
	order_children()
	#if map:
		#map.emit_signal("thing_removed",child)
	#if child is Wall:
	#	var above_cell = $"..".get_cell_or_null(cell_position + Vector3.BACK)
	#	if above_cell:
	#		for thing in above_cell.contents:
	#			thing.gravity()

func add_thing(thing): # Create or move a thing to this tile
	if thing is GDScript:
		thing = thing.new()
	add_child(thing)
	if map: map.update()
	return thing
