extends Thing
class_name Item
tool
# Items are objects like food and weapons

# warning-ignore:unused_class_variable
var use_time = 10

func _init():
	type = "Item"

func use(_user: Thing, _args: Array) -> void:
	pass

func _on_designate(designator):
	._on_designate(designator)
	if designator.name == "Forbid":
		toggle_forbidden()
