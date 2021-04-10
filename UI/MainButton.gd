extends Button

export(String) var id = ""

func _init() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed",self,"_on_mainbutton_pressed",[id])
