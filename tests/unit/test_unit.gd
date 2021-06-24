extends "res://addons/gut/test.gd"

class TestMap extends "res://addons/gut/test.gd":
	var map = null
	func before_all():
		map = autofree(Map.new(Vector3.ZERO))

class TestStringGenerators extends "res://addons/gut/test.gd":
	var style = Globals.BAR_FOR_TEST
	func test_generate_ascii_bar_full():
		var string = Globals.generate_ascii_progress_bar(100,10,style)
		assert_eq(string,"0".repeat(10))
	
	func test_generate_ascii_bar_half():
		var string = Globals.generate_ascii_progress_bar(50,10,style)
		assert_eq(string,"0000044444")
	
	func test_generate_ascii_bar_half_with_odd_size():
		var string = Globals.generate_ascii_progress_bar(50,11,style)
		assert_eq(string,"00000244444")
	
	func test_generate_ascii_bar_almost_full():
		var string = Globals.generate_ascii_progress_bar(99,10,style)
		assert_eq(string,"0".repeat(9) + "1")
	
	func test_generate_ascii_bar_almost_empty():
		var string = Globals.generate_ascii_progress_bar(1,10,style)
		assert_eq(string,"3" + "4".repeat(9))
	
	func test_generate_ascii_bar_all_numbers(param=use_parameters(range(0,100))):
		var string = Globals.generate_ascii_progress_bar(param,10,style)
		assert_eq(string.length(),10)
