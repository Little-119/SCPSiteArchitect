extends Node

var current_map = null setget set_current_map
# warning-ignore:unused_class_variable
var maps: Array = []

var turn_timer := Timer.new()
var turn: int = 0

func set_current_map(map: Map):
	current_map = map
	if map is Map:
		map.visible = true
		for m in get_children():
			if m is Map and m != map:
				m.visible = false

func _init() -> void:
	turn_timer.name = "TurnTimer"
	turn_timer.wait_time = .1
	# warning-ignore:return_value_discarded
	turn_timer.connect("timeout",self,"on_turn")
	add_child(turn_timer)

func set_process(enable: bool) -> void:
	turn_timer.paused = enable
	.set_process(enable)

func load_world() -> void:
	var map0 = (load("res://Map.gd") as GDScript).new(Vector3(64,64,1))
	map0.name = "TestMap"
	add_child(map0)
	map0.load_submap((load("res://Maps/TestMap.tscn") as PackedScene).instance(),Vector3(2,2,0))
	set_current_map(map0)

func _ready() -> void:
	load_world()
	turn_timer.start()
	
	#var gut = (load("res://tests/tests.tscn") as PackedScene).instance()
	if not OS.has_feature("standalone"):
		pass
		#($"/root/Player/Camera2D/Debug" as Control).add_child(gut)
		#($"/root/Player/Camera2D/Debug" as Control).visible = Settings.get("debug_gut_visible")

func _unhandled_input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			match (event as InputEventKey).scancode:
				KEY_F1:
					if OS.is_debug_build():
						($"/root/Player/Camera2D/Debug" as Control).visible = not ($"/root/Player/Camera2D/Debug" as Control).visible
						Settings.set("debug_gut_visible",($"/root/Player/Camera2D/Debug" as Control).visible)
						get_tree().set_input_as_handled()

func on_turn() -> void:
	turn += 1
