extends Node2D
class_name Cell
# A cell is a space in which Things often exist. Probably should've been called tiles.

export var is_default_cell: bool = false # Whether this is the Default Cell or not.

var map = null # Map that this Cell is part of
var contents: Array = [] # List of Things in the cell. get_children() does the same thing unless Cells ever get non-Thing children
export var cell_position := Vector3.ZERO setget set_cell_position # This Cell's position on the grid

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
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE*Constants.cell_size),Color(.15,.15,.15))

func set_cell_position(newpos: Vector3 = cell_position) -> void:
	position = Vector2(newpos.x * Constants.cell_size,newpos.y * Constants.cell_size)
	($"Spatial" as Spatial).transform.origin = Vector3(newpos.x,newpos.z,newpos.y)
	cell_position = newpos

func get_adjacent_cell(offset: Vector3) -> Cell:
	if map:
		return map.get_cell(Vector3(cell_position.x+offset.x,cell_position.y-offset.y,cell_position.z-offset.z))
	else:
		# warning-ignore:unsafe_cast
		return (Constants.default_cell as Cell)

func get_cells_in_directions(directions: Array) -> Array:
	var adjacent_cells = []
	for direction in directions:
		if direction == Vector3.ZERO: continue
		var adj_cell = get_adjacent_cell(direction)
		if not adj_cell.is_default_cell: # collect only non-default cells
			adjacent_cells.append(adj_cell)
	return adjacent_cells

func get_four_adjacent_cells() -> Array: # adjacent, excluding diagonals
	return get_cells_in_directions([Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT])

func get_six_adjacent_cells() -> Array: # adjacent including up and down
	return get_four_adjacent_cells() + get_cells_in_directions([Vector3.FORWARD,Vector3.BACK])

func get_eight_adjacent_cells() -> Array: # adjacent including diagonal on the same Z-Level
	return get_four_adjacent_cells() + get_cells_in_directions([Vector3.UP+Vector3.LEFT,Vector3.UP+Vector3.RIGHT,Vector3.DOWN+Vector3.LEFT,Vector3.DOWN+Vector3.RIGHT])

func get_twentysix_adjacent_cells() -> Array: # this is big brain time probably. I don't even know what I'm going to use these functions for.
	var cells = get_eight_adjacent_cells()
	for z in [Vector3.FORWARD,Vector3.BACK]:
		var dirs = [Vector3.ZERO,Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.UP+Vector3.LEFT,Vector3.UP+Vector3.RIGHT,Vector3.DOWN+Vector3.LEFT,Vector3.DOWN+Vector3.RIGHT]
		for i in dirs.size():
			dirs[i] += z
		cells += get_cells_in_directions(dirs)
	return cells

func get_cells_in_radius(radius: float,multi_z: bool = false) -> Array: # TODO: this can probably be optimized
	var cells = []
	for cell in map.cells:
		if cell_position.distance_to(cell.cell_position) <= radius and (not multi_z or cell.cell_position.z == cell_position.z):
			cells.append(cell)
	return cells

func on_left_click(event: InputEventWithModifiers) -> void: # called in Map.gd. Probably could be called here, too bad!
	var thing_to_select
	var selected_at: int = contents.size()
	if $"/root/Game/Player".get("selection").size() > 0:
		for selected in $"/root/Game/Player".get("selection"):
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
		# warning-ignore:unsafe_method_access
		$"/root/Game/Player".select(thing_to_select,not event.shift)
		get_tree().set_input_as_handled()

func on_right_click(event: InputEventWithModifiers) -> void:
	var actions: Array = []
	var actionable_results: Dictionary = {}
	var actions_script: GDScript = load("res://Actions.gd")
	# warning-ignore:unsafe_property_access
	if $"/root/Game/Player".selection.empty():
		return
	# warning-ignore:unsafe_property_access
	for selected in $"/root/Game/Player".selection:
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
				var action_node = actions_script[action_name].new(selected,false)
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
			button.text = " " + action if not actionable_results.has(action) else " %s (%s)" % [action,actionable_results[action].details]
			if actionable_results.has(action):
				# warning-ignore:unsafe_property_access
				# warning-ignore:unsafe_property_access
				if actionable_results[action].code == actions_script.STATUS.FAIL or actionable_results[action].code == actions_script.STATUS.ERROR:
					button.disabled = true
			panel.add_child(button)
			button.rect_size = Vector2(128,30)
			button.rect_position += Vector2(0,20 * (get_child_count()-1))
			button.align = Button.ALIGN_LEFT
			button.connect("pressed", panel, "queue_free")
			# warning-ignore:unsafe_property_access
			for selected in $"/root/Game/Player".selection:
				button.connect("pressed", selected, "force_action", [action,self], CONNECT_ONESHOT)
		$"/root/Game/Player/Camera2D/UI".add_child(panel,true)
		panel.name = "ActionsCard"

		panel.rect_position = get_global_mouse_position() + (get_viewport().size/2) - ($"/root/Game/Player/Camera2D" as Camera2D).position # TODO: I forget how to get the screen position of a cell.

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
	assert(child)
	var old_parent
	if child.get("type"): # 'if child is Thing' causes an error. Workaround: see if it has a property called type
		old_parent = child.get_node_or_null("..")
		if old_parent:
			old_parent.remove_child(child)
		contents.append(child)
		order_children()
		# warning-ignore:unsafe_method_access
		child.on_moved(old_parent)
	.add_child(child,b)
	if not old_parent or (map != old_parent.get("map")):
		if child.get("type"):
			map.emit_signal("thing_added",child)
			if child.get("astar"):
				# warning-ignore:unsafe_property_access
				child.astar.refresh()
				map.connect("thing_added",child,"_on_map_added_thing")
	zlevel_update(null)

func remove_child(child: Node) -> void:
	if child.get("type"):
		contents.erase(child)
	.remove_child(child)
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
