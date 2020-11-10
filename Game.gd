extends Node

var current_map = null setget set_current_map
# warning-ignore:unused_class_variable
var maps: Array = []

var turn_timer := Timer.new()
var turn: int = 0

func set_current_map(map):
	current_map = map
	current_map.visible = true
	for m in get_children():
		if m is Map and m != current_map:
			m.visible = false

func _init() -> void:	
	turn_timer.name = "TurnTimer"
	turn_timer.wait_time = .01
	# warning-ignore:return_value_discarded
	turn_timer.connect("timeout",self,"on_turn")
	add_child(turn_timer)

func set_process(enable: bool) -> void:
	turn_timer.paused = enable
	.set_process(enable)

func load_world() -> void:
	var map0 = (load("res://Map.gd") as GDScript).new()
	map0.name = "TestMap"
	add_child(map0)
	map0.load_submap((load("res://Maps/TestMap.tscn") as PackedScene).instance(),Vector3(2,2,0))
	set_current_map(map0)

func _ready() -> void:
	load_world()
	turn_timer.start()
	if OS.is_debug_build():
		var gut = (load("res://test/tests.tscn") as PackedScene).instance()
		gut.visible = false
		$"/root/Player/Camera2D/Debug".add_child(gut)

func _input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			match (event as InputEventKey).scancode:
				KEY_F1:
					($"/root/Player/Camera2D/Debug" as Control).visible = not ($"/root/Player/Camera2D/Debug" as Control).visible

func on_turn() -> void:
	turn += 1
