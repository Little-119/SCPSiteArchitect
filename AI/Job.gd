extends Node
class_name Job

# Jobs represent work that can be done on things, such as constructing.
# Jobs should be performer-agnostic to some degree, doable by, say, any willing worker
# This is how they differ from drives. Drives are performer-centered, jobs are thing-to-be-worked-on cenetered
# e.g. for constructing, the Job node would be a child of the structure to be built
# Jobs can be defined in the AI folder or in the file of the thing they're bespokely created for

var reserved_by

func _init():
	add_to_group("Jobs")

func do(actor) -> void:
	pass

func on_done(actor) -> void:
	pass

func cancel():
	queue_free()
