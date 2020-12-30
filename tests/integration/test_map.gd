extends "res://addons/gut/test.gd"

var map_size := Vector3(16,16,2)

var universe = null
var map: Map = null

func before_each():
	universe = (load("res://Universe.gd") as GDScript).new()
	map = Map.new(map_size) # Make a new map, resetting us to a clean slate
	universe.add_child(map)
	universe.set_current_map(map)
	add_child(universe)

func after_each():
	map.free()
	universe.free()

func test_map_functioning(): # Test if map system is functioning (i.e. loading of maps, getting cells from them, etc)
	assert_is(universe,load("res://Universe.gd"))
	assert_is(map,Map)
	var out_of_bounds_position: Vector3 = map_size + Vector3.RIGHT
	for position in [Vector3.ONE,map_size-Vector3.ONE,out_of_bounds_position]:
		var cell = map.get_cell(position)
		assert_not_null(cell)
		assert_is(cell,Cell)
		if position == out_of_bounds_position:
			assert_true(cell.is_default_cell)
			assert_eq(cell.cell_position,Vector3(-1,-1,0))
		else:
			assert_false(cell.is_default_cell)
			assert_eq(cell.cell_position,position)
	var cell: Cell = map.get_cell(Vector3.ONE)
	assert_eq(cell.contents.size(), 0)
	for thing in [Thing, Thing.new()]:
		var new_thing = cell.add_thing(thing)
		assert_is(new_thing,Thing)
		assert_has(cell.contents,new_thing)
		assert_eq(new_thing.cell,cell)
		assert_eq(new_thing.map,map)

func test_actor_actions():
	var cell: Cell = map.get_cell(Vector3(2,2,0))
	var target = Vector3(15,15,0)
	var actor = cell.add_thing(Actor)
	var action_one = actor.force_action("MoveTo",target)
	action_one.no_free_when_done = true
	action_one.move_turns = 0
	(universe.get_node("TurnTimer") as Timer).start()
	
	yield(yield_to(action_one,"finished",5),YIELD)
	assert_signal_emitted(action_one,"finished")
	assert_eq(actor.cell.cell_position, target)
	assert_eq(action_one.last_think_result.code, load("res://Actions.gd").STATUS.DONE)
	action_one.free()
	
	var action_two = actor.force_action("MoveTo", Vector3(-2,-2,-1))
	yield(yield_to(action_two,"finished",5),YIELD)
	assert_signal_emitted(action_two,"finished")
