extends Structure
class_name Door
tool

# warning-ignore:unused_class_variable
var requires_fine_manipulation: bool = true
# warning-ignore:unused_class_variable
var requires_id_access = []

func _init().():
	type = "Door"
	character = "D"
