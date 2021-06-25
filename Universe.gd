extends Node2D
class_name Universe
# Universes are collections of maps, with their own turn timer

const TIME_SPEED: Dictionary = {SLOW=.5,NORMAL=1,FAST=2,FASTER=3,FASTEST=5}
# Enum for timescale multipliers. const dictionary because enums don't allow floats, only ints

var maps: Array = []
var current_map = null setget set_current_map

var turn_timer: CustomTurnTimer = CustomTurnTimer.new()
var turn: int = 0

class CustomTurnTimer extends Timer:
	var default_wait_time: float = ProjectSettings.get_setting("Game/turn_length")
	
	func _init():
		name = "TurnTimer"
		wait_time = default_wait_time
	
	func get_time_scale() -> float:
		return default_wait_time / wait_time
	
	func set_time_scale(value: float) -> void:
		wait_time = default_wait_time * (1/value)
	

func set_current_map(map: Map):
	current_map = map
	if map is Map:
		map.visible = true
		for m in get_children():
			if m is Map and m != map:
				m.visible = false

func _init(to_load = null) -> void:
	pause_mode = PAUSE_MODE_STOP
	if to_load:
		var map = Map.load_map(to_load)
		add_child(map,true)
		set_current_map(map)
	# warning-ignore:return_value_discarded
	turn_timer.connect("timeout",self,"on_turn")
	add_child(turn_timer)

func add_child(node: Node, legible_unique_name: bool = false):
	if node is Map:
		maps.append(node)
		node.name = "Map " + str(node.get_instance_id())
	.add_child(node,legible_unique_name)

func on_turn() -> void:
	turn += 1
	for map in maps:
		var threads: Array = []
		var start = OS.get_ticks_usec()
		for thing in map.things:
			var t = Thread.new()
			t.start(thing,"on_turn_async")
			threads.append(t)
		for t in threads:
			t.wait_to_finish()
		for thing in map.things:
			thing.on_turn()

func set_process(enable: bool) -> void:
	turn_timer.paused = not enable
	.set_process(enable)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.is_action_type(): # ordered by usage, probably. Yes this is apparently the best way to do this with InputActions
			if event.is_action("time_normal"):
				turn_timer.set_time_scale(TIME_SPEED.NORMAL)
			elif event.is_action("time_faster"):
				turn_timer.set_time_scale(TIME_SPEED.FASTER)
			elif event.is_action("time_slow"):
				turn_timer.set_time_scale(TIME_SPEED.SLOW)
			elif event.is_action("time_fastest"):
				turn_timer.set_time_scale(TIME_SPEED.FASTEST)
			elif event.is_action("time_fast"):
				turn_timer.set_time_scale(TIME_SPEED.FAST)
