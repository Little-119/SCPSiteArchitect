extends "res://addons/gut/test.gd"

var game

func before_each():
	game = load("res://tests/assets/DebugGame.tscn").instance()
	var universe = game.setup_universe(false)
	var map = (load("res://tests/assets/DebugMap.gd") as GDScript).new()
	map.set_size(Vector3(4,4,1))
	universe.add_child(map)
	universe.set_current_map(map)
	game.set_current_universe(universe)
	add_child(game)

func after_each():
	game.free()
	.after_each()
