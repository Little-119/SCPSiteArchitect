extends "res://addons/gut/test.gd"

var map_size := Vector3(16,16,2)

var universe = null
var map: Map = null

func before_each():
	universe = Universe.new(null)
	universe.turn_timer.wait_time = .001
	universe.visible = false
	map = Map.new(map_size) # Make a new map, resetting us to a clean slate
	universe.add_child(map)
	universe.set_current_map(map)
	add_child(universe)

func after_each():
	universe.free()

var cell_getting_params = [[Vector3.ONE, Vector3.ONE, false], [map_size-Vector3.ONE, map_size-Vector3.ONE, false], [map_size + Vector3.RIGHT, Vector3(-1,-1,0), true]]
func test_cell_getting(params=use_parameters(cell_getting_params)):
	var cell = map.get_cell(params[0])
	assert_not_null(cell)
	assert_is(cell,Cell)
	assert_eq(cell.is_default_cell,params[2])
	assert_eq(cell.cell_position,params[1])

var thing_placement_params = [[Thing], [Thing.new()]]
func test_cell_thing_placement(params=use_parameters(thing_placement_params)): # Test if map system is functioning (i.e. loading of maps, getting cells from them, etc)
	var cell: Cell = map.get_cell(Vector3.ONE)
	var new_thing = cell.add_thing(params[0])
	assert_is(new_thing,Thing)
	assert_has(cell.contents,new_thing)
	assert_eq(new_thing.cell,cell)
	assert_eq(new_thing.map,map)
