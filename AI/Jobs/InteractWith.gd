extends Job
class_name InteractWith

func do(actor):
	if not actor.is_adjacent(get_parent()):
		var adjacent_spot = actor.find_adjacent_spot(get_parent().cell) # potentially too expensive to call this often
		if adjacent_spot and not actor.doing_action("MoveTo",adjacent_spot):
			actor.do_action("MoveTo",adjacent_spot)
	else:
		on_done(actor)

# warning-ignore:unused_argument
func on_done(actor):
	queue_free()
