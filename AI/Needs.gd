# see AI/AI DOCUMENTATION.txt for documentation on this

class Hunger extends Need:
	var nutrition: float = 810.0
	var nutrition_capacity: float = 2000.0
	func _init():
		type = "Hunger"
	func on_life_process():
		nutrition -= 1
	func on_ai_process():
		if get_magnitude() <= .4:
			actor.add_drive("Eat",Actor.PRIORITY.NEED + 5,true)
		else:
			actor.remove_drive("Eat")
		.on_ai_process()
	func get_magnitude():
		magnitude = (nutrition / nutrition_capacity)
		return .get_magnitude()
