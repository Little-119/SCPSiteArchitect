extends Panel

func _init() -> void:
	var actors: Array = ThingsManager.get_things_of_type("Actor")
	name = "HirePanel"
	for i in actors.size():
		var item: Thing = actors[i]
		print(item)
		if item.abstract:
			continue
		var b := Button.new()
		b.clip_text = true
		b.text = item.type
		b.rect_size = Vector2(64,64)
		b.light_mask = 0
		# warning-ignore:return_value_discarded
		b.connect("pressed",self,"equip_buildable",[b,item])
		add_child(b)

func _ready():
	for child in get_children():
		if child is Button:
			remove_child(child)
			$"Container".add_child(child)
