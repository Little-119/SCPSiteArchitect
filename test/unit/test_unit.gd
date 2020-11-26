extends "res://addons/gut/test.gd"

class TestMap extends "res://addons/gut/test.gd": # tests for in-game date function
	var map = null
	func before_all():
		map = autofree(load("res://Map.gd").new(Vector3.ZERO))
	
	func test_thirtysec():
		assert_eq(map.get_local_time(30).seconds,30 * Constants.turn_length)
	
	#func test_oneandhalfminute():
		#assert_eq(map.get_local_time(130 * Constants.turn_length).seconds,10)
