extends Thing
class_name Item

var use_time = 10

func _init():
	type = "Item"

func use(consumer: Thing) -> void:
	pass
