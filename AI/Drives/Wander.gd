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
		var destinations: Array = actor.cell.get_cells_in_radius(3)
		destinations.shuffle()
		var destination: Cell = null
		for cell in destinations:
			if actor.astar.test_path_to(cell):
				#destination = cell
				destination = actor.cell.get_adjacent_cell(Vector3(0,-2,0))
				break
		if destination:
			moveto = actor.do_action("MoveTo",destination,self)
