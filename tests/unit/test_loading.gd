extends "res://addons/gut/test.gd"

class TestMapCreation extends "res://addons/gut/test.gd":
	func test_blank_map():
		var map = Map.load_map(null)
		assert_is(map,Map)
	
	func test_load_from_scene():
		var test_map_path = "res://Maps/LoadingTestMap.tscn"
		var test_map = load(test_map_path)
		if test_map is PackedScene:
			test_map = test_map.instance()
		assert_is(test_map,Map,"Test map is not valid, unable to perform test")
		if not test_map is Map:
			return
		test_map.free()
		var map = Map.load_map(test_map_path)
		assert_is(map,Map)
		if not map is Map:
			return
		var cell_with_stuff = map.get_cell(Vector3(1,1,0))
		assert_eq(cell_with_stuff.contents.size(),2)
		assert_is(cell_with_stuff.contents.front(), Humanoid, "Cell does not contain expected contents")
		map.free()
	
	func test_submap():
		var test_map = load("res://Maps/LoadingTestMap.tscn")
		if test_map is PackedScene:
			test_map = test_map.instance()
		assert_is(test_map,Map,"Test map is not valid, unable to perform test")
		if not test_map is Map:
			return
		var map = Map.new(Vector3(4,4,1))
		map.load_submap(test_map,Vector3(1,1,0))
		
		var cell_with_stuff = map.get_cell(Vector3(2,2,0))
		assert_gt(cell_with_stuff.contents.size(),0)
		assert_is(cell_with_stuff.contents.front(), Humanoid, "Cell does not contain expected contents")
		map.free()
	
	func test_load_from_save():
		pending("Test unimplemented")
