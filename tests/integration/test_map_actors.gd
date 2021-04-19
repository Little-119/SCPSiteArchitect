extends "res://tests/integration/test_map.gd"

var actor: Actor

func before_each():
	.before_each()
	actor = Actor.new()

func after_each():
	actor.queue_free()
	.after_each()

func test_actor_moveto():
	universe.name = "TestBasicMoveTo"
	map.get_cell(Vector3(2,2,0)).add_thing(actor)
	var target = Vector3(15,15,0)
	var action: Actions.MoveTo = actor.act("MoveTo",map.get_cell(target),true)
	action.move_turns = 0
	universe.turn_timer.start()
	
	yield(yield_to(action,"finished",5),YIELD)
	assert_signal_emitted(action,"finished")
	assert_eq(actor.cell.cell_position, target)
	assert_eq(action.last_think_result.code, Actions.STATUS.DONE)
	action.free()

func test_actor_pathfinding():
	universe.name = "TestPathfindingMoveTo"
	map.get_cell(Vector3(2,2,0)).add_thing(actor)
	for position in [Vector3(3,1,0),Vector3(3,2,0),Vector3(3,3,0)]:
		map.get_cell(position).add_thing(Wall)
	var target = Vector3(4,2,0)
	var action: Actions.MoveTo = actor.act("MoveTo",map.get_cell(target),true)
	action.move_turns = 0
	universe.turn_timer.start()
	
	yield(yield_to(action,"finished",5),YIELD)
	assert_signal_emitted(action,"finished")
	assert_eq(actor.cell.cell_position, target)
	assert_eq(action.last_think_result.code, Actions.STATUS.DONE)
	action.free()

var prisons = [[Cell.FOUR],[Cell.EIGHT]]
func test_actor_imprisonment(params=use_parameters(prisons)): # Encase actor in walls, tell them to move, expect it to fail
	universe.name = "TestImprisonedMoveTo"
	var start_cell: Cell = map.get_cell(Vector3(2,2,0))
	start_cell.add_thing(actor)
	for cell in start_cell.call("get_adjacent_cells",params[0]):
		cell.add_thing(Wall)
	var target = map.get_cell(Vector3(4,4,0))
	var action = actor.act("MoveTo",null,true)
	action.target = target
	action.move_turns = 0
	universe.turn_timer.start()
	yield(yield_to(action,"finished",1),YIELD)
	
	assert_signal_emitted(action,"finished")
	assert_eq(actor.cell, start_cell)
	assert_not_null(action.last_think_result)
	if action.last_think_result:
		assert_eq(action.last_think_result.details, "No path")
	action.free()

func test_actor_groundedness():
	universe.name = "TestGroundedMoveTo"
	var start_cell: Cell = map.get_cell(Vector3(2,2,0))
	start_cell.add_thing(actor)
	var action = actor.act("MoveTo",null,true)
	action.move_turns = 0
	action.target = map.get_cell(Vector3(2,2,1))
	universe.turn_timer.start()
	yield(yield_to(action,"finished",1),YIELD)
	
	assert_signal_emitted(action,"finished")
	assert_eq(actor.cell, start_cell)
	assert_not_null(action.last_think_result)
	if action.last_think_result:
		assert_eq(action.last_think_result.details, "No path")
	action.free()

func test_actor_moveto_invalid():
	universe.name = "TestInvalidMoveTo"
	var start_cell: Cell = map.get_cell(Vector3(2,2,0))
	start_cell.add_thing(actor)
	var action = actor.act("MoveTo",null,true)
	watch_signals(action)
	action.move_turns = 0
	action.target = map.get_cell(Vector3(-3,-5,-4))
	universe.turn_timer.start()
	
	assert_signal_emitted(action,"finished")
	assert_eq(actor.cell, start_cell)
	assert_eq(action.last_think_result.details, "Error: MoveTo needs a non-default Cell as a target")
	action.free()
