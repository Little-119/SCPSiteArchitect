extends "res://addons/gut/test.gd"

class TestMap extends "res://addons/gut/test.gd":
	var map = null
	func before_all():
		map = autofree(Map.new(Vector3.ZERO))
