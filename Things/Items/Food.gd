extends Item
class_name Food
tool

var nutrition: float = 1500.0

func _init():
	type = "Food"
	character = "o"
	use_time = 10

func use(user: Thing) -> void:
	user.needs_dict.Hunger.nutrition += nutrition
	queue_free()
