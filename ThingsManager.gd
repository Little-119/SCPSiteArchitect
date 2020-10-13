extends Node
# This is a helper class that can be used to get collections of Things, and such

var things: Dictionary = {}
var things_list: Array = []

# warning-ignore:unused_class_variable
var next_thing_uid: int = 0

func get_files_in_directory(dir_path: String = "res://") -> Array:
	var dir: Directory = Directory.new()
	var err = dir.open(dir_path)
	var files := []
	if err:
		print("Failed to open %s with error code %s" % [dir_path, err])
		return files
	err = dir.list_dir_begin()
	if err:
		print("Failed to read %s with error code %s" % [dir_path, err])
		return files
	
	while true:
		var file: String = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			if dir.current_is_dir():
				files += get_files_in_directory(dir_path + file + "/")
			else:
				files.append(dir_path + file)
	dir.list_dir_end()
	return files

func _init() -> void:
	var thing_files = get_files_in_directory("res://Things/")
	for file_name in thing_files:
		var thing: Thing = (load(file_name) as GDScript).new()
		thing.set_process(false)
		things_list.append(thing)
		things[thing.type] = thing

func get_things_of_type(typename: String = "Thing",exclude_parent = true) -> Array:
	var type: Thing = things[typename] # get an instance of the Thing
	var type_script: GDScript = type.get_script() # get the GDScript for the Thing. I'm still not sure if I understand the difference
	var things_of_type: Array = []
	for thing in things_list:
		if thing is type_script:
			if exclude_parent and thing.type == type.type:
				continue
			things_of_type.append(thing)
	return things_of_type

func sort_for_layering(a,b): # Sort Things by layer, then by UID. Place non-Things last. For use with Array.sort
	if not b is Thing:
		return true
	if not a is Thing:
		return false
	if a.layer == b.layer:
		return a.uid < b.uid
	return a.layer < b.layer
