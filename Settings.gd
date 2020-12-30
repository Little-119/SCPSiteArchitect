extends Node

var settings_file: File

var settings: Dictionary = {debug_gut_visible = false}

func _init() -> void:
	settings_file = File.new()
	if not settings_file.file_exists("user://settings.txt"):
		var err: int = settings_file.open("user://settings.txt",File.WRITE)
		if err != OK: push_error("Error when creating settings: " + str(err))
		settings_file.close()
	var err: int = settings_file.open("user://settings.txt",File.READ)
	if err != OK: push_error("Error when reading settings:" + str(err))

	var regex = RegEx.new() # unnecessary regex
	regex.compile("^(.+)=(.*)#?")
	while true:
		var data: String = settings_file.get_line()
		var result: RegExMatch = regex.search(data)
		if result:
			if result.strings[1] in settings:
				var value = result.strings[2]
				if value.to_lower() == "true":
					value = true
				elif value.to_lower() == "false":
					value = false
				elif value.is_valid_integer():
					value = int(value)
				elif value.is_valid_float():
					value = float(value)
				settings[result.strings[1]] = value
		if settings_file.eof_reached():
			break
	settings_file.close()

func write():
	var err: int = settings_file.open("user://settings.txt",File.WRITE)
	if err != OK: push_error("Error when writing settings:" + str(err))
	settings_file.store_line("# Config file. Be careful when editing this! Extra text or invalid changes may be overwritten.")
	for key in settings:
		settings_file.store_line("%s=%s" % [key,settings[key]])
	settings_file.close()

func set(key,value) -> void:
	settings[key] = value

func get(key):
	return settings[key]

func _notification(what):
	if what == NOTIFICATION_PREDELETE: # if this autoload is getting deleted, assume the program is exiting. Note that this apparently wont fire when the game is killed in the editor
		write()
