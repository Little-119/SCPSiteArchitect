extends Node

var current_universe: Universe setget set_current_universe

func set_current_universe(new_universe):
	if new_universe == null:
		current_universe = null
	elif new_universe is Universe:
		current_universe = new_universe

func get_current_map():
	if current_universe:
		return current_universe.current_map
	else:
		return null

func _ready() -> void:
	var gut = (load("res://tests/tests.tscn") as PackedScene).instance()
	$"DebugContainer".add_child(gut)
	if not OS.has_feature("standalone"):
		($"DebugContainer" as Control).visible = Settings.get("debug_gut_visible")
	var autoloadmap = Settings.get("autoloadmap")
	match autoloadmap:
		null, false:
			return
		true, TYPE_STRING:
			var universe = Universe.new(autoloadmap)
			universe.name = "Universe"
			universe.current_map.set_size(Vector3(32,32,2))
			var player = load("res://Player.tscn").instance()
			add_child(universe,true)
			add_child(player,true)
			current_universe = universe

func _unhandled_input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			match (event as InputEventKey).scancode:
				KEY_ESCAPE:
					# TODO: Add exit confirmation of some kind
					get_tree().set_input_as_handled()
					get_tree().quit(0)
				KEY_F1:
					if not OS.has_feature("standalone"):
						var new_gut_visibility: bool = not Settings.get("debug_gut_visible")
						Settings.set("debug_gut_visible",new_gut_visibility)
						($"DebugContainer" as Control).visible = new_gut_visibility
						get_tree().set_input_as_handled()
