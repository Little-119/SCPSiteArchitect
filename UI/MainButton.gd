extends Button

export(String) var id = ""

func _init() -> void:
	connect("pressed",self,"_on_mainbutton_pressed",[id])
