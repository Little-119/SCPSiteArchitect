extends Button
class_name GuardedButton

signal second_pressed

var primed: bool = false
var original_text: String = ""
export(String) var uncovered_text: String = "(ARE YOU SURE?)"
export(float,0,5) var debounce_time: float = 0.5

func _init():
	# warning-ignore:return_value_discarded
	connect("pressed",self,"_on_pressed")

func _on_pressed():
	if get_node_or_null("Timer"):
		pass
	elif not primed or not require_primed():
		if get_node_or_null("Timer"):
			$"Timer".queue_free()
		if debounce_time != 0:
			var debounce_timer: Timer = Timer.new()
			debounce_timer.one_shot = true
			debounce_timer.autostart = true
			debounce_timer.wait_time = debounce_time
			# warning-ignore:return_value_discarded
			debounce_timer.connect("timeout",debounce_timer,"queue_free")
			# warning-ignore:return_value_discarded
			debounce_timer.connect("tree_exiting",self,"set_disabled",[false])
			add_child(debounce_timer,true)
		primed = true
		original_text = text
		text = uncovered_text
		disabled = true
	else:
		primed = false
		text = original_text
		emit_signal("second_pressed")

func require_primed() -> bool:
	return true
