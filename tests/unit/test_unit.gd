extends "res://addons/gut/test.gd"

class TestMap extends "res://addons/gut/test.gd": # tests for in-game date function
	var map = null
	func before_all():
		map = autofree(Map.new(Vector3.ZERO))
