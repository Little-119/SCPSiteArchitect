extends Thing
class_name Item
tool
# Items are objects like food and weapons

# warning-ignore:unused_class_variable
var use_time = 10

func _init():
	type = "Item"

func use(_user: Thing) -> void:
	pass
