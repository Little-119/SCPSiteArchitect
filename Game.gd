extends Node

var current_map = null setget set_current_map
# warning-ignore:unused_class_variable
var maps: Array = []

var default_cell: Cell = Cell.new()
var TurnTimer := Timer.new()

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
	
	TurnTimer.name = "TurnTimer"
	TurnTimer.wait_time = .01
	add_child(TurnTimer)

func load_world() -> void:
	var map0 = (load("res://Map.gd") as GDScript).new(Vector3(16,16,1))
	map0.name = "Map0"
	add_child(map0)
	set_current_map(map0)

func _ready() -> void:
	load_world()
	TurnTimer.start()
