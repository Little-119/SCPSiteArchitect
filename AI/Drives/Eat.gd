extends "Drive.gd"

func _init():
	type = "eat"
	display_name = "Eating"

var food

func act_async(_userdata):
	food = actor.find_closest_thing_of_type(ThingsManager.get_thing_script("Food"),true,true)
	
func act():
	.act()
	if not food:
		return 1
	elif actor.doing_action("UseItem",food,self):
		return 0
	else:
		actor.do_action("UseItem",food,self)
		return 0
