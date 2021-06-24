extends "Drive.gd"

func _init():
	type = "sleep"
	display_name = "Sleeping"

func find_bed_filter(thing: Thing) -> bool:
	if thing is Structure and "rest_effectiveness" in thing:
		return true
	return false

func act():
	#var bed = actor.find_closest_thing_of_type(ThingsManager.get_thing_script("Food"),true,true)
	var bed: Thing = actor.get_meta("Bed").get_ref() if actor.has_meta("Bed") else null
	if bed == null:
		var beds: Array = actor.find_things_custom(self,"find_bed_filter")
		beds.sort_custom(actor, "sort_things_by_distance")
		for prospective_bed in beds:
			if prospective_bed.asignee:
				continue
			bed = prospective_bed
		if bed:
			bed.asignee = weakref(actor)
			actor.set_meta("Bed",weakref(bed))
	
	if not bed:
		return 1
	elif actor.doing_action("UseStructure",bed,self):
		return 0
	else:
		actor.do_action("UseStructure",bed,self)
		return 0
