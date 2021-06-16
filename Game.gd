extends Node
# 'Main' node for managing the whole game

var current_universe: Universe setget set_current_universe
# warning-ignore:unused_class_variable
var current_map: Map setget ,get_current_map # for convenience/consistency with current_universe
var paused: bool = false setget set_paused

func set_current_universe(new_universe):
	if not new_universe:
		set_paused(false)
	if current_universe:
		current_universe.set_process(false)
		current_universe.visible = false
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
		set_current_universe(universe)
		universe.turn_timer.start()

func new_game():
	var new_universe: Universe = setup_universe(false)
	var map = Map.new(Vector3(32,32,1))
	new_universe.add_child(map)
	new_universe.set_current_map(map)
	($"/root/Game/Player/Camera2D" as Camera2D).position = Vector2.ZERO
	set_current_universe(new_universe)
	new_universe.turn_timer.start()

func _ready() -> void:
	ready() # allows correctly overriding this in DebugGame

func _unhandled_input(event: InputEvent):
	if event.is_pressed() and not event.is_echo():
		if event.is_action("menu"):
			if not get_node_or_null("/root/Game/Player/Camera2D/UI/PauseMenu"):
				get_tree().set_input_as_handled()
				($"/root/Game/Player/Camera2D/UI" as Control).add_child((load("res://UI/PopupMenus/PauseMenu.tscn") as PackedScene).instance())
			set_paused(not paused)
		elif event.is_action("toggle_godotunittesting"):
			if OS.is_debug_build():
				var new_gut_visibility: bool = not Settings.get("debug_gut_visible")
				Settings.set("debug_gut_visible",new_gut_visibility)
				($"DebugContainer" as Control).visible = new_gut_visibility
				get_tree().set_input_as_handled()

func set_paused(enable: bool) -> void:
	if not current_universe:
		return
	paused = enable
	for child in get_children():
		if child is Universe:
			child.set_process(not enable)
