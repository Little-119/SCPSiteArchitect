extends Job
class_name InteractWith

func do(actor):
	if not actor.is_adjacent(get_parent()):
		if not actor.doing_action("MoveTo",get_parent().cell):
			actor.do_action("MoveTo",get_parent().cell)
	else:
		on_done(actor)

func on_done(actor):
	queue_free()
