class BaseNeed extends Reference:
	var type: String
	var actor: Actor
	var magnitude: float = 0.0 setget ,get_magnitude
	func _init():
		type = "BaseNeed"
	func on_life_process():
		pass
	func on_ai_process():
		pass
	func get_magnitude():
		return magnitude

class Hunger extends BaseNeed:
	var nutrition: float = 810.0
	var nutrition_capacity: float = 2000.0
	func _init():
		type = "Hunger"
	func on_life_process():
		nutrition -= 1
	func on_ai_process():
		if get_magnitude() <= .4:
			actor.add_drive("Eat",Actor.PRIORITY.NEED + 5,true)
		.on_ai_process()
	func get_magnitude():
		magnitude = (nutrition / nutrition_capacity)
		return .get_magnitude()
