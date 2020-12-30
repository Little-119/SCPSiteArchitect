extends Node

func _ready() -> void:
	var gut = (load("res://tests/tests.tscn") as PackedScene).instance()
	$"GUTContainer".add_child(gut)
	if not OS.has_feature("standalone"):
		$"GUTContainer".visible = Settings.get("debug_gut_visible")

func _unhandled_input(event: InputEvent):
	if event.is_pressed():
		if event is InputEventKey:
			match (event as InputEventKey).scancode:
				KEY_ESCAPE:
					# TODO: Add exit confirmation of some kind
					get_tree().set_input_as_handled()
					get_tree().quit(0)
				KEY_F1:
					if not OS.has_feature("standalone"):
						var new_gut_visibility: bool = not Settings.get("debug_gut_visible")
						Settings.set("debug_gut_visible",new_gut_visibility)
						$"GUTContainer".visible = new_gut_visibility
						get_tree().set_input_as_handled()
