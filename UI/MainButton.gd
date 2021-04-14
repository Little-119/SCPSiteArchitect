extends Button

export(String) var id = ""

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed",$"..","_on_mainbutton_pressed",[id])
