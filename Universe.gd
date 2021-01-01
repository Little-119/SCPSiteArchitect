extends Node
class_name Universe

var maps: Array = []
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

func add_child(node: Node, legible_unique_name: bool = false):
	if node is Map:
		maps.append(node)
	.add_child(node,legible_unique_name)

func on_turn() -> void:
	turn += 1
	for map in maps:
		(map as Node).propagate_call("on_turn",[],true)

func set_process(enable: bool) -> void:
	turn_timer.paused = enable
	.set_process(enable)
