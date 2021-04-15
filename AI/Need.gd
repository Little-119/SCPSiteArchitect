extends Reference
class_name Need

var type: String = "Need"
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
