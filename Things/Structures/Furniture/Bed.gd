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

func use(user: Thing, args: Array):
	if "needs_dict" in user:
		var sleep_need: Need = user.needs_dict["Sleep"]
		sleep_need.rest += sleep_need.REST_DRAIN_PER_TURN + (1 * rest_effectiveness)
		return 0
