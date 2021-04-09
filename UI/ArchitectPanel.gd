extends "res://UI/MainPanel.gd"

func _init() -> void:
	var buildables: Array = ThingsManager.get_things_of_type("Structure")
	name = "ArchitectPanel"
	panel_size = Vector2(8 + 64 + 8 + 64 + 8, 8 + 64 + 8 + 64 + 8 + 64 + 8) # temporary
	# TODO: Format this UI
	for i in buildables.size():
		var item: Thing = buildables[i]
		var b := Button.new()
		b.clip_text = true
		b.text = item.type
		b.margin_top = i * 64
		b.margin_bottom = b.margin_top + 64
		b.margin_right = 64
		b.light_mask = 0
		# warning-ignore:return_value_discarded
		b.connect("pressed",self,"equip_buildable",[b,item])
		add_child(b)
