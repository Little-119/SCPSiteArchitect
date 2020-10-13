extends Node2D
class_name Cell
# A cell is a space in which Things often exist. Probably should've been called tiles.

var is_default_cell: bool = false # Whether this is the Default Cell or not.

var map = null # Map that this Cell is part of
var contents: Array = [] # List of Things in the cell. get_children() does the same thing unless Cells ever get non-Thing children
var cell_position := Vector3.ZERO setget set_cell_position # This Cell's position on the grid

# warning-ignore:unused_class_variable
var point_id: int = 0 # The cell's point ID in the parent map's AStar

func _to_string():
	return name

func _init():
	z_index -= 1

func _ready():
	name = "Cell %s" % cell_position if not is_default_cell else "DefaultCell"
	#add_thing(ThingsManager.things["Thing"].get_script().new())

func _draw():
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE*Constants.cell_size),Color(.15,.15,.15))

func set_cell_position(newpos: Vector3 = cell_position) -> void:
	position = Vector2(newpos.x * Constants.cell_size,newpos.y * Constants.cell_size)
	cell_position = newpos

func get_adjacent_cell(offset: Vector3) -> Cell:
	if map:
		var ac = map.get_cell(Vector3(cell_position.x+offset.x,cell_position.y-offset.y,cell_position.z-offset.z))
		return ac
	else:
		# warning-ignore:unsafe_property_access
		return $"/root/Game".default_cell

func get_cells_in_directions(directions: Array) -> Array:
	var adjacent_cells = []
	for direction in directions:
		if direction == Vector3.ZERO: continue
		adjacent_cells.append(get_adjacent_cell(direction))
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

func on_left_click() -> void:
	pass

func on_right_click() -> void:
	pass

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
	if is_default_cell:
		return
	if not zlevel is int:
		# specifying type as Map causes cyclic dependency
		# warning-ignore:unsafe_property_access
		zlevel = $"..".current_zlevel
	var diff = cell_position.z - zlevel
	visible = diff <= 0 and diff >= -3
	modulate = Color(1,1,1,clamp(1-(diff/-4),0,1))

func add_child(child: Node,b: bool=false) -> void:
	if child.get("type"): # 'if child is Thing' causes an error. Workaround: see if it has a property called type
		var parent = child.get_node_or_null("..")
		if parent:
			parent.remove_child(child)
		contents.append(child)
		order_children()
	.add_child(child,b)
	zlevel_update(null)

func remove_child(child: Node) -> void:
	if child.get("type"):
		contents.erase(child)
	.remove_child(child)
	order_children()
	#if child is Wall:
	#	var above_cell = $"..".get_cell_or_null(cell_position + Vector3.BACK)
	#	if above_cell:
	#		for thing in above_cell.contents:
	#			thing.gravity()

func add_thing(thing) -> void: # Create or move a thing to this tile
	if thing is GDScript:
		thing = thing.new()
	add_child(thing)
	if map: map.update()
