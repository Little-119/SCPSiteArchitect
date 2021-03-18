
class Eat extends BaseDrive:
	func _init():
		type = "eat"
		display_name = "Eating"
	
	func act():
		.act()
		var food = actor.find_closest_thing_of_type(ThingsManager.get_thing_script("Food"),true,true)
		if not food:
			return false
		else:
			actor.do_action("UseItem",food,self)
			return true

class Wander extends BaseDrive:
	var moveto
	
	func _init():
		type = "wander"
		display_name = "Wandering"
	
	func act():
		.act()
		if not moveto:
			var destinations = []
			for cell in actor.cell.get_cells_in_radius(3):
				if actor.is_cell_impassable(cell):
					continue
				if cell == actor.cell:
					continue
				if not actor.astar.test_path_to(cell):
					continue
				destinations.append(cell)
			if not destinations.empty():
				var destination = destinations[randi() % destinations.size()]
				moveto = actor.do_action("MoveTo",destination,self)

class Labor extends BaseDrive:
	func _init():
		type = "labor"

class Construct extends Labor:
	func _init():
		type = "construct"
		display_name = "Constructing"
	
	var blueprint
	
	func act():
		if not blueprint:
			return
		