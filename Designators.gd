class Designator extends Reference:
	# warning-ignore:unused_class_variable
	var name: String
	var text: String setget ,get_text # character (or characters) to use for designator button icon
	var text_color: Color = Color.white setget ,get_text_color
	var icon: Texture setget ,get_icon
	# warning-ignore:unused_class_variable
	var selection: Array
	# warning-ignore:unused_class_variable
	var key: int
	
	func on_activate():
		pass
	
	func get_text() -> String: return text
	func get_text_color() -> Color: return text_color
	func get_icon() -> Texture: return icon

class Deconstruct extends Designator:
	func _init():
		name = "Deconstruct"
		text = "-"
		text_color = Color.orange
		key = KEY_X

class Forbid extends Designator:
	func _init():
		name = "Forbid"
		text = "F"
		key = KEY_F
	
	func get_text_color():
		return Color.red if (selection.front().get_meta("forbidden") if selection.front().has_meta("forbidden") else false) else Color.green
