extends "Drive.gd"

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
