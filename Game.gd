extends Node

var current_map = null setget set_current_map
# warning-ignore:unused_class_variable
var maps: Array = []

var default_cell: Cell = Cell.new()
var turn_timer := Timer.new()
var turn: int = 0

func set_current_map(map):
	current_map = map
	current_map.visible = true
	for m in get_children():
		if m is Map and m != current_map:
			m.visible = false

func _init() -> void:
	default_cell.is_default_cell = true
	default_cell.visible = false
	default_cell.cell_position = Vector3(-1,-1,0)
	add_child(default_cell)
	
	turn_timer.name = "TurnTimer"
	turn_timer.wait_time = .01
	# warning-ignore:return_value_discarded
	turn_timer.connect("timeout",self,"on_turn")
	add_child(turn_timer)

func set_process(enable: bool) -> void:
	turn_timer.paused = enable
	.set_process(enable)

func load_world() -> void:
	var map0 = Map.new(Vector3(16,16,1))
	map0.name = "Map0"
	add_child(map0)
	set_current_map(map0)

func _ready() -> void:
	load_world()
	turn_timer.start()

func on_turn() -> void:
	turn += 1
