
class Work extends Drive:
	func _init():
		type = "work"
		display_name = "Working"
	
	func act():
		var jobs = actor.get_tree().get_nodes_in_group("Jobs")
		jobs.sort_custom(actor, "sort_jobs_by_distance")
		if not jobs.empty():
			for job in jobs:
				if job.reserved_by and job.reserved_by != actor:
					continue
				else:
					job.reserved_by = actor
					job.do(actor)
					return 0
		return 1

class Eat extends Drive:
	func _init():
		type = "eat"
		display_name = "Eating"
	
	func act():
		.act()
		var food = actor.find_closest_thing_of_type(ThingsManager.get_thing_script("Food"),true,true)
		if not food:
			return 1
		elif actor.doing_action("UseItem",food,self):
			return 0
		else:
			actor.do_action("UseItem",food,self)
			return 0

class Wander extends Drive:
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
				if not actor.astar.test_path_to(cell):
					continue
				destinations.append(cell)
			if not destinations.empty():
				var destination = destinations[randi() % destinations.size()]
				moveto = actor.do_action("MoveTo",destination,self)
