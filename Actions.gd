extends Node

class BaseAction:
	extends Node
	var type: String = "BaseAction"
	var actioner: Actor
	# warning-ignore:unused_class_variable
	var target = null
	# warning-ignore:unused_class_variable
	var path: PoolVector3Array
	# warning-ignore:unused_class_variable
	var progress: int = 0
	enum FAILURE_CODE {NO_PATH}
	# warning-ignore:unused_class_variable
	var failures: Array = []
	func _init(new_actioner: Actor) -> void:
		actioner = new_actioner
		actioner.actions.append(self)
		actioner.add_child(self)
	func _to_string() -> String:
		return "[%s:%s (Owner: %s)]" % [type,get_instance_id(),actioner]
	func think() -> void:
		pass
	func execute() -> void:
		pass
	func finish() -> void:
		queue_free()
	func fail() -> void:
		finish()

class MoveTo: # Move between cells on one map
	extends BaseAction
	func _init(new_actioner: Actor).(new_actioner):
		type = "MoveTo"
	func think() -> void:
		if not (target is Cell):
			push_error("MoveTo needs a Cell as a target.")
			fail()
		if (actioner.cell as Cell).get("map") != target.map: # TODO: Pathing between maps
			push_error("MoveTo between maps is unimplemented.")
			fail()
		if actioner.cell == target: # We're already at the destination
			finish()
		if actioner.astar.ready:
			# warning-ignore:unsafe_property_access
			path = actioner.astar.get_point_path(actioner.cell.point_id,target.point_id)
			if path.size() == 0:
				fail()
			else:
				path.remove(0)
	func execute() -> void:
		if not path or path.size() == 0:
			think()
			failures.append(FAILURE_CODE.NO_PATH)
			if failures.count(FAILURE_CODE.NO_PATH) > 3:
				fail()
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
