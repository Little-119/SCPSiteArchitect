extends Thing
class_name Item
# Items are objects like food and weapons

var use_time = 10

func _init():
	type = "Item"

func use(consumer: Thing) -> void:
	pass
