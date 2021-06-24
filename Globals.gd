extends Node
# warning-ignore-all:unused_class_variable
# Contains global variables and functions to be accessed by other scripts

var god_mode: bool = false # god mode allows instant (de)construction. Here so Structures can access it before entering the tree

const BAR_FOR_TEST = "01234" # GUT can't render special characters in its output apparently
const BAR_BLOCK_FADING_STYLE = "█▓▒░_"
const BAR_BLOCK_STYLE = "▉▊▌▎ "
const BAR_CDDA_STYLE = "|\\\\\\."

static func generate_ascii_progress_bar(percent: float,size: int,style: String = BAR_BLOCK_FADING_STYLE) -> String:
	percent = round(percent)
	var to_fill = size * (percent / 100)
	var remainder = fmod(to_fill,1)
	var middle_char: String
	match (remainder * 10) as int:
		1,2,3:
			middle_char = style[3]
		4,5,6:
			middle_char = style[2]
		7,8,9:
			middle_char = style[1]
	
	var front: String = style[0].repeat(floor(to_fill)) if floor(to_fill) > 0 else ""
	var to_fill_r: int = size - (front.length() + middle_char.length())
	var back: String = style[4].repeat(to_fill_r) if to_fill_r > 0 else ""
	var string: String = front + middle_char + back
	if string.length() != size: breakpoint
	return string
