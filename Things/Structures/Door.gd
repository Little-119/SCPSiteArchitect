extends Structure
class_name Door
tool

var requires_fine_manipulation: bool = true
var requires_id_access = []

func _init().():
	type = "Door"
	character = "D"
