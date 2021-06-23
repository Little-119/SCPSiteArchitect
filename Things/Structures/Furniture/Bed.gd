extends "Furniture.gd"
class_name Bed
tool

enum {ASIGNEE_DCLASS=1}

var rest_effectiveness: float = .7

func _init().():
	type = "Bed"
	character = "b"

func set_asignee(value):
	if asignee and asignee.get_ref():
		#asignee.get_ref().remove_meta("Bed")
		pass
	asignee = value
