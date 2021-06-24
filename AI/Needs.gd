# see AI/AI DOCUMENTATION.txt for documentation on this

class Hunger extends Need:
	var nutrition: float = 810.0
	var nutrition_capacity: float = 2000.0
	func _init():
		type = "Hunger"
		display_name = "Nutrition"
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

class Sleep extends Need:
	const REST_DRAIN_PER_TURN: int = 1
	var rest: float = 300.0 setget set_rest
	var rest_capacity: float = 1000.0
	func _init():
		type = "Sleep"
	func get_magnitude():
		magnitude = (rest / rest_capacity)
		return .get_magnitude()
	func on_life_process():
		self.rest -= REST_DRAIN_PER_TURN
	static func actor_is_sleeping(actor) -> bool:
		for action in actor.get_actions():
			if action is Actions.UseStructure and action.target and "rest_effectiveness" in action.target:
				return true
		return false
	func on_ai_process():
		if get_magnitude() <= .3:
			actor.add_drive("Sleep",Actor.PRIORITY.NEED - 5,true)
		else:
			if not actor_is_sleeping(actor) or get_magnitude() >= .95:
				actor.remove_drive("Sleep")
	func set_rest(value: float):
		rest = clamp(value, 0, rest_capacity)
