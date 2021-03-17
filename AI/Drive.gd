extends Reference
class_name BaseDrive

# warning-ignore:unused_class_variable
var actor: Actor
var type: String
var display_name setget ,get_display_name # name to display to player. can be set in init to override without writing logic
# warning-ignore:unused_class_variable
var priority: float = 0

func _to_string():
	return type + " " + str(priority)

func _init():
	type = "basedrive"

func get_display_name() -> String: # returns name to display to player when indicating what actor is doing
	return type.capitalize() if not display_name else display_name.capitalize()

func act() -> void:
	return
