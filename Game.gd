extends Node
# 'Main' node for managing the whole game

var current_universe: Universe setget set_current_universe
# warning-ignore:unused_class_variable
var current_map: Map setget ,get_current_map # for convenience/consistency with current_universe

func set_current_universe(new_universe):
	if new_universe == null:
		current_universe = null
	elif new_universe is Universe:
		current_universe = new_universe

func get_current_map():
	if current_universe:
		return current_universe.get("current_map")
	else:
		return null

func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node, legible_unique_name)
	move_child($"DebugContainer",get_child_count())

func setup_universe(from) -> Universe:
	var universe = Universe.new(from)
	universe.name = "Universe"
	add_child(universe,true)
	if $"DebugContainer".get_child_count() > 0:
		($"DebugContainer" as Control).rect_position = get_viewport().size/-2
	return universe

func ready() -> void:
	if OS.is_debug_build(): 
		var gut = (load("res://tests/tests.tscn") as PackedScene).instance()
		$"DebugContainer".add_child(gut)
		($"DebugContainer" as Control).visible = Settings.get("debug_gut_visible")
	var autoloadmap = Settings.get("autoloadmap")
	if not autoloadmap:
		return
	elif typeof(autoloadmap) == TYPE_BOOL or typeof(autoloadmap) == TYPE_STRING:
		var universe: Universe = setup_universe(autoloadmap)
		current_universe = universe
		universe.turn_timer.start()

func _ready() -> void:
	ready() # allows correctly overriding this in DebugGame

func _unhandled_input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			match (event as InputEventKey).scancode:
				KEY_ESCAPE:
					# Overlaps with use of KEY_ESCAPE in Player
					if not get_node_or_null("/root/Game/Player/Camera2D/UI/PauseMenu"):
						get_tree().set_input_as_handled()
						($"/root/Game/Player/Camera2D/UI" as Control).add_child((load("res://UI/PauseMenu.tscn") as PackedScene).instance())
					get_tree().paused = not get_tree().paused
				KEY_QUOTELEFT:
					if OS.is_debug_build():
						get_tree().set_input_as_handled()
						get_tree().quit(0)
				KEY_F1: # Toggles GUT visibility
					if OS.is_debug_build():
						var new_gut_visibility: bool = not Settings.get("debug_gut_visible")
						Settings.set("debug_gut_visible",new_gut_visibility)
						($"DebugContainer" as Control).visible = new_gut_visibility
						get_tree().set_input_as_handled()
