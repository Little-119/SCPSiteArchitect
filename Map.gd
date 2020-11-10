extends Node2D
class_name Map

# warning-ignore:unused_signal
signal thing_added # emitted in Cell.add_child
# warning-ignore:unused_signal
signal thing_removed

const max_size := Vector3(512,512,32)
export(Vector3) var size: Vector3 setget set_size
var cells_matrix := [] # 3-D array of cells. In order of Z(-levels), then Y, then X
var cells := [] # 1-D list of all cells in map

var current_zlevel: int = 0 # displayed z-level

var astar := AStar.new() # Let us meet again as stars.

func _to_string():
	return "Map"

var orphaned_things: Array = [] # Array of Things not in a cell, presumably because they were added in editor

func set_size(newsize: Vector3) -> void:
	size = newsize
	# warning-ignore:narrowing_conversion
	astar.reserve_space(newsize.x*newsize.y*newsize.z)
	# warning-ignore:narrowing_conversion
	cells_matrix.resize(clamp(size.z,cells_matrix.size(),max_size.z))
	for zn in size.z:
		var y := []
		# warning-ignore:narrowing_conversion
		y.resize(clamp(size.y,y.size(),max_size.y))
		for yn in size.y:
			var x := []
			# warning-ignore:narrowing_conversion
			x.resize(clamp(size.x,x.size(),max_size.x))
			for xn in size.x:
				if x[xn] is Cell:
					continue
				var nc: Cell = Cell.new()
				cells.append(nc)
				x[xn] = nc
				nc.cell_position = Vector3(xn,yn,zn)
				# don't know why this produces an unsafe property access warning
				# warning-ignore:unsafe_property_access
				nc.map = self
				nc.point_id = astar.get_point_count()
				astar.add_point(nc.point_id,nc.cell_position)
				add_child(nc)
			y[yn] = x
		cells_matrix[zn] = y
	update()

func _init(newsize: Vector3 = Vector3(64,64,1)) -> void:
	size = newsize
	z_index = -1
	set_size(size)

func get_pixel_size() -> Vector2:
	var cell_size = Constants.cell_size
	return Vector2(size.x * cell_size,size.y * cell_size)

func _ready() -> void:
	for child in get_children():
		if child is Thing:
			remove_child(child)
			child.request_ready()
			orphaned_things.append(child)
			
	for cell in cells:
		for adj_cell in cell.get_eight_adjacent_cells():
			if not astar.are_points_connected(cell.point_id,adj_cell.point_id):
				astar.connect_points(cell.point_id,adj_cell.point_id)
	for i in orphaned_things.size():
		var thing = orphaned_things[i]
		if not thing: continue
		var adoptive_cell: Cell = get_cell(Vector3(thing.position.x,thing.position.y,thing.position_z))
		if adoptive_cell:
			adoptive_cell.add_child(thing)
			orphaned_things.remove(i)
			i -= 1
	
	#get_cell(Vector3(5,5,1)).add_thing(PlayerControlledActor)
	# warning-ignore:unsafe_property_access
	$"/root/Game".maps.append(self)
	# warning-ignore:return_value_discarded
	$"/root/Player".connect("camera_moved",self,"update")
	#get_cell(Vector3(1,1,0)).add_thing(OneSevenThree)

func load_submap(submap: Map, offset: Vector3) -> void: # offset defines position of the upper left corner of the submap
	var orphans: Array = []
	for child in submap.get_children():
		if not (child is Cell):
			submap.remove_child(child)
			orphans.append(child)
	for cell in submap.cells:
		for child in cell.contents:
			cell.remove_child(child)
			child.request_ready()
			child.position = Vector2(cell.cell_position.x,cell.cell_position.y)
			child.position_z = cell.cell_position.z
			orphans.append(child)
	for orphan in orphans:
		var adoptive_cell = get_cell_or_null(offset + Vector3(orphan.position.x,orphan.position.y,orphan.position_z))
		if adoptive_cell:
			orphan.position = Vector2.ZERO
			orphan.position_z = 0
			adoptive_cell.add_child(orphan)
	submap.queue_free()

func get_cell(pos: Vector3) -> Cell: # get cell with cell_position
	if pos.x >= 0 and pos.y >= 0 and pos.z >= 0 and cells_matrix.size() > pos.z and cells_matrix[pos.z].size() > pos.y and cells_matrix[pos.z][pos.y].size() > pos.x:
		return cells_matrix[pos.z][pos.y][pos.x]
	else:
		# warning-ignore:unsafe_property_access
		return $"/root/Game".default_cell

func get_cell_or_null(pos: Vector3) -> Cell:
	var c: Cell = get_cell(pos)
	if c.is_default_cell:
		return null
	else:
		return c

func clamp_to_cell_grid(num: float) -> int:
	return int(floor(num / Constants.cell_size))

func get_cell_from_position(from_position: Vector2,z:int = 0) -> Cell:
	var rounded_position = Vector3.ZERO
	rounded_position.x = clamp_to_cell_grid(from_position.x)
	rounded_position.y = clamp_to_cell_grid(from_position.y)
	rounded_position.z = z
	return get_cell(rounded_position)

func get_cell_from_screen_position(from_position: Vector2,z:int = 0) -> Cell: # get cell from local screen position
	from_position += ($"/root/Player/Camera2D" as Camera2D).get_camera_position() - ($"/root" as Viewport).size/2
	return get_cell_from_position(from_position,z)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		# event.global_position does not contain the actual global position, or at least not the global position that's needed here
		var cell_at_pos: Cell = get_cell_from_position(get_global_mouse_position(),current_zlevel)
		if event is InputEventMouseMotion:
			update()
			if cell_at_pos and (not cell_at_pos.is_default_cell):
				cell_at_pos.on_mouseonto()
		
		if event is InputEventMouseButton:
			if (event as InputEventMouseButton).pressed:
				if cell_at_pos and (not cell_at_pos.is_default_cell):
					match (event as InputEventMouseButton).button_index:
						1:
							cell_at_pos.on_left_click()
							# can't specify that Player is a Player while it's a Singleton
							# warning-ignore:unsafe_property_access
							if $"/root/Player".mousetool:
								# warning-ignore:unsafe_property_access
								$"/root/Player".mousetool.tool_lclick_oncell(cell_at_pos)
						2:
							cell_at_pos.on_right_click()

func view_zlevel(z: int = 0) -> void: # change map view to a different z-level
	# warning-ignore:narrowing_conversion
	z = clamp(z,0,cells_matrix.size()-1)
	current_zlevel = z
	for cell in cells:
		cell.zlevel_update(z)

func view_zlevel_incr(delta: int) -> void: # change map view to a different z-level, based on the one we're currently looking at
	view_zlevel(current_zlevel + delta)

func _draw() -> void:
	# as said above, can't specify that Player is a Player while it's a Singleton
	# warning-ignore:unsafe_property_access
	if $"/root/Player".mousetool:
		var cell: Cell = get_cell_from_position(get_global_mouse_position(),current_zlevel)
		if not cell.is_default_cell:
			var box_pos: Vector2 = cell.position
			draw_rect(Rect2(box_pos,Vector2.ONE * cell.scale.x * 32),Color.white,false)
