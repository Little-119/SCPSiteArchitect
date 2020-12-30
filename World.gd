extends Node

var current_map = null setget set_current_map

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
	
	# This part loads a test map. For testing. TEMPORARY, TODO: Remove this when it's no longer needed
	var map0 = (load("res://Map.gd") as GDScript).new(Vector3(64,64,1))
	map0.name = "TestMap"
	add_child(map0)
	map0.load_submap((load("res://Maps/TestMap.tscn") as PackedScene).instance(),Vector3(2,2,0))
	set_current_map(map0)

func on_turn() -> void:
	turn += 1

func set_process(enable: bool) -> void:
	turn_timer.paused = enable
	.set_process(enable)
