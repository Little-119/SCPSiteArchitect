extends Control

const mainbuttons := ["Architect"]
var mainbutton_size := 64
var mainbutton_margin := 32
var mainbutton_spacing := 16

const mainpanels := preload("res://MainPanels.gd")

func _init() -> void:
	light_mask = 0
	for i in mainbuttons.size():
		var b := Button.new()
		b.focus_mode = Button.FOCUS_NONE
		b.text = mainbuttons[i]
		b.clip_text = true
		b.anchor_bottom = 1
		b.anchor_top = 1
		b.margin_bottom = -mainbutton_margin
		b.margin_top = b.margin_bottom - mainbutton_size
		b.margin_left = -(b.margin_bottom) + ((mainbutton_spacing + mainbutton_size) * i)
		b.margin_right = b.margin_left + mainbutton_size
		b.light_mask = 0
		# warning-ignore:return_value_discarded
		b.connect("pressed",self,"_on_mainbutton_pressed",[mainbuttons[i]])
		add_child(b)

func update_size() -> void:
	rect_size = ($"/root" as Viewport).size
	rect_position = ($"/root" as Viewport).size / -2

func _ready():
	update_size()
	# warning-ignore:return_value_discarded
	$"/root".connect("size_changed",self,"update_size")

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
