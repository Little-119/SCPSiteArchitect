extends Reference
class_name Need

# warning-ignore:unused_class_variable
var type: String = "Need"
var display_name: String setget ,get_display_name
# warning-ignore:unused_class_variable
var actor: Actor
var magnitude: float = 0.0 setget ,get_magnitude

func _init():
	pass

func on_life_process():
	pass

func on_ai_process():
	pass

func get_magnitude():
	return magnitude

func get_display_name():
	return display_name if not display_name.empty() else type
