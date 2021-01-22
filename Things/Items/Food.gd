extends Item
class_name Food

var nutrition: float = 1500.0

func _init():
	type = "Food"
	icon = "o"

func use(user: Thing) -> void:
	user.needs_dict.Hunger.nutrition += nutrition
	queue_free()
