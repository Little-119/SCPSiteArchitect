extends "Drive.gd"

var moveto

func _init():
	type = "wander"
	display_name = "Wandering"

func act():
	.act()
	if not moveto in actor.actions:
		moveto = null
	if not moveto:
		var destinations = []
		for cell in actor.cell.get_cells_in_radius(3):
			if actor.is_cell_impassable(cell):
				continue
			if cell == actor.cell:
				continue
			# test_path_to is defined in CustomAStar (inner class in Actor.gd)
			# warning-ignore:unsafe_method_access
			if not actor.astar.test_path_to(cell):
				continue
			destinations.append(cell)
		if not destinations.empty():
			var destination = destinations[randi() % destinations.size()]
			moveto = actor.do_action("MoveTo",destination,self)
