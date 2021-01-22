class BaseDrive extends Reference:
	# warning-ignore:unused_class_variable
	var actor: Actor
	var type: String
	# warning-ignore:unused_class_variable
	var priority: float = 0
	func _to_string():
		return type + " " + str(priority)
	
	func _init():
		type = "basedrive"
	
	func act():
		return

class Eat extends BaseDrive:
	func _init():
		type = "eat"
	
	func act():
		.act()
		var food = actor.find_closest_thing_of_type(ThingsManager.get_thing_script("Food"),true)
		if not food:
			return false
		else:
			actor.do_action("UseItem",food)
			return true
