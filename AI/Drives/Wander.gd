extends "Drive.gd"

var moveto
var destination: Cell = null

func _init():
	type = "wander"
	display_name = "Wandering"

func act_async(_userdata):
	if not moveto and not destination:
		var destinations: Array = actor.cell.get_cells_in_radius(3)
		var destination: Cell = null
		while not destinations.empty():
			# randomly pick a cell, check if it's reachable. If not, pick another one, repeat
			var i: int = (randi() % destinations.size())
			var cell: Cell = destinations[i]
			if not actor.astar.test_path_to(cell):
				destinations.remove(i)
				continue
			else:
				destination = cell
				break

func act():
	.act()
	if not moveto in actor.actions:
		moveto = null
	if not moveto:
		if destination:
			moveto = actor.do_action("MoveTo",destination,self)
			destination = null
