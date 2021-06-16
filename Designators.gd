class Designator extends Reference:
	var button: Button setget set_button
	# warning-ignore:unused_class_variable
	var name: String
	var text: String setget ,get_text # character (or characters) to use for designator button icon
	var label_text: String
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
	
	func set_button(new_button: Button) -> void:
		new_button.text = text
		text_color = get_text_color()
		new_button.add_color_override("font_color",text_color)
		new_button.add_color_override("font_color_hover",text_color)
		var regex = RegEx.new()
		regex.compile("(?<!^\\W)[AEIOUaeiou]") # match vowels, unless they're the first character of a word
		var button_label_text = label_text
		if not label_text:
			button_label_text = name
			prints(button_label_text,button_label_text.length())
			if button_label_text.length() > 6:
				button_label_text = regex.sub(button_label_text,"",true)
		(new_button.get_node("Label") as Label).text = button_label_text.substr(0,6)
		button = new_button

class Deconstruct extends Designator:
	func _init():
		name = "Deconstruct"
		text = "-"
		text_color = Color.orange
		key = KEY_X
	
	func set_button(new_button: Button):
		var second_text: Label = new_button.get_node("SecondText")
		second_text.add_color_override("font_color",Color.red)
		second_text.add_color_override("font_color_hover",Color.red)
		second_text.text = "\\" if selection.front().get_meta_or_null("deconstructing") else ""
		.set_button(new_button)

class Forbid extends Designator:
	func _init():
		name = "Forbid"
		text = "F"
		key = KEY_F
	
	func get_text_color():
		return Color.red if selection.front().get_meta_or_null("forbidden") else Color.green
