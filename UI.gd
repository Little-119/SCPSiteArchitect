extends Control

const mainbuttons := ["Architect"]
var mainbutton_size := 64
var mainbutton_margin := 32
var mainbutton_spacing := 16

const mainpanels := preload("res://MainPanels.gd")

func _init() -> void:
	for i in mainbuttons.size():
		var b := Button.new()
		b.text = mainbuttons[i]
		b.clip_text = true
		b.anchor_bottom = 1
		b.anchor_top = 1
		b.margin_bottom = -mainbutton_margin
		b.margin_top = b.margin_bottom - mainbutton_size
		b.margin_left = -(b.margin_bottom) + ((mainbutton_spacing + mainbutton_size) * i)
		b.margin_right = b.margin_left + mainbutton_size
		b.rect_size = Vector2.ONE * 64
		b.light_mask = 0
# warning-ignore:return_value_discarded
		b.connect("pressed",self,"_on_mainbutton_pressed",[mainbuttons[i]])
		add_child(b)

func _draw() -> void:
	# warning-ignore:unsafe_property_access
	if $"/root/Player".mousetool:
		var mousepos: Vector2 = ($"/root" as Viewport).get_mouse_position()
		# warning-ignore:unsafe_property_access
		var map: Map = $"/root/Game".current_map
		var cell: Cell = map.get_cell_from_screen_position(mousepos,map.current_zlevel)
		if not cell.is_default_cell:
			pass
			#var box_pos: Vector2 = mousepos - Vector2(int(mousepos.x) % 32,int(mousepos.y) % 32)
			#var box_pos: Vector2 = cell.global_position - $"/root/Player/Camera2D".position
			#draw_rect(Rect2(box_pos,Vector2.ONE * 32),Color.white,false)

func _process(_delta) -> void:
	update()

func _on_mainbutton_pressed(button_name: String) -> void:
	match button_name:
		"Architect":
			if has_node("ArchitectPanel"):
				$"ArchitectPanel".queue_free()
			else:
# warning-ignore:return_value_discarded
				mainpanels.ArchitectPanel.new(self)