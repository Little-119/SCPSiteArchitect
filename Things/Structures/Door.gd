extends Structure
class_name Door

var requires_fine_manipulation: bool = true
var requires_id_access = []

func _init().():
	type = "Door"
	icon = "D"
