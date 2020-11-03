extends Node

class BaseAction:
	extends Node
	var type: String = "BaseAction"
	var actioner: Actor
	# warning-ignore:unused_class_variable
	var target
	# warning-ignore:unused_class_variable
	var path: PoolVector3Array
	# warning-ignore:unused_class_variable
	var progress: int = 0
	func _init(new_actioner: Actor) -> void:
		actioner = new_actioner
		actioner.actions.append(self)
		actioner.add_child(self)
	func _to_string():
		return "[%s:%s (Owner: %s)]" % [type,get_instance_id(),actioner]
	func think() -> void:
		pass
	func execute() -> void:
		pass
	func finish() -> void:
		queue_free()
	func fail() -> void:
		finish()

class MoveTo:
	extends BaseAction
	func _init(new_actioner: Actor).(new_actioner):
		type = "MoveTo"
	func think():
		if actioner.astar.ready:
			# warning-ignore:unsafe_property_access
			path = actioner.astar.get_point_path(actioner.cell.point_id,actioner.map.get_cell(target).point_id)
			if path.size() == 0:
				fail()
			else:
				path.remove(0)
	func execute():
		if not path or path.size() == 0:
			think()
		if progress < 100:
			progress += 1
		else:
			var result: int = actioner.move_to(path[0])
			if result != Actor.MOVE_OK:
				think()
			else:
				if path.size() == 1:
					finish()
				path.remove(0)
				progress = 0
