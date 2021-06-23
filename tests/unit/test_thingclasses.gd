extends "res://addons/gut/test.gd"

var thing_files: Array
var things: Array

func before_all():
	thing_files = ThingsManager.get_files_in_directory("res://Things/")
	things = ThingsManager.things_list

func test_type_matches_filename():
	for i in things.size():
		var thing: Thing = things[i]
		var file_path: String = thing_files[i]
		var file_name = file_path.get_file().substr(0,len(file_path.get_file())-3)
		assert_eq(thing.type, file_name, "Thing Class in %s does not have type matching file name" % file_name)

func test_is_tool():
	for i in things.size():
		var thing: Thing = things[i]
		var file_path: String = thing_files[i]
		var script: Script = thing.get_script()
		# All Things should have a Tool keyword to function properly when editing maps in the Godot editor
		assert_true(script.is_tool(),"%s (at path %s) lacks tool keyword" % [thing.type,file_path])
