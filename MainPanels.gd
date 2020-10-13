class MainPanel extends Panel:
	var panel_size := Vector2(64,64)
	func _init(UI: Control) -> void:
		name = "MainPanel"
		light_mask = 0
		# warning-ignore:unsafe_property_access
		margin_bottom = (UI.mainbutton_margin * -1.5) - UI.mainbutton_size
		# warning-ignore:unsafe_property_access
		margin_left = UI.mainbutton_margin
		anchor_bottom = 1
		anchor_top = 1
	func resize() -> void:
		margin_top = margin_bottom - panel_size.y
		margin_right = margin_left + panel_size.x
	func _ready() -> void:
		resize()
	func equip_buildable(button,buildable) -> void:
		button.get_node("/root/Player").equip_tool(buildable)
		queue_free()

class ArchitectPanel extends MainPanel:
	func _init(UI: Control).(UI) -> void:
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
		#for thing in items:
			#thing.free()
		UI.add_child(self)
