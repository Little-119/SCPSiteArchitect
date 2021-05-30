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
	designators.append("forbid")

func _on_designate(designator):
	._on_designate(designator)
	if designator.name == "Forbid":
		toggle_forbidden()
