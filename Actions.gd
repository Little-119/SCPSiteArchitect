extends Node

enum STATUS {OK,NEW,DONE=4,FAIL,ERROR}

class ThinkResult extends Reference:
	var code: int = STATUS.NEW
	var details: String = "Generic reason"
	func _init(c: int = STATUS.NEW,d: String = details):
		code = c
		details = d

class BaseAction extends Node:
	# warning-ignore:unused_class_variable
	var type: String setget ,get_class
	func get_class() -> String: return "BaseAction"
	# warning-ignore:unused_class_variable
	var status: int = STATUS.NEW
	var allowed_execute: bool = true # checked in Actor.gd before calling execute
	var actioner: Actor
	# warning-ignore:unused_class_variable
	var target = null setget set_target
	func set_target(new_target) -> void:
		target = new_target
		# warning-ignore:unsafe_property_access
		if actioner in $"/root/Player".selection:
			# warning-ignore:unsafe_method_access
			$"/root/Player".update_selection_card()
	# warning-ignore:unused_class_variable
	var path: PoolVector3Array
	# warning-ignore:unused_class_variable
	var progress: int = 0
	enum FAILURE {NO_PATH}
	# warning-ignore:unused_class_variable
	var failures: Array = []
	func _init(new_actioner: Actor = null,allow_execute: bool = true,add_to_queue: bool = false) -> void:
		allowed_execute = allow_execute
		actioner = new_actioner
		if allow_execute:
			if not add_to_queue:
				actioner.actions.clear()
				actioner.actions.insert(0,self)
			else:
				actioner.actions.append(self)
		actioner.add_child(self,true)
		# warning-ignore:unsafe_property_access
		if (actioner in $"/root/Player".selection) and allow_execute:
			# warning-ignore:unsafe_method_access
			$"/root/Player".update_selection_card()
			if actioner.get("map"):
				actioner.get("map").update()
	func _to_string() -> String:
		var text: String = "[%s:%s (Owner: %s)]" % [get_class(),get_instance_id(),actioner]
		if not allowed_execute:
			text += " (nonexecutable)"
		return text
	func get_display_name() -> String:
		return "BaseAction"
	func think() -> ThinkResult:
		return ThinkResult.new()
	func execute() -> void:
		pass
	func finish() -> void:
		if actioner in $"/root/Player".selection:
			$"/root/Player".update_selection_card()
		queue_free()
	func fail() -> void:
		finish()
	func is_actionable(_tgt) -> bool:
		return true

class MoveTo extends BaseAction: # Move between cells on one map
	func _init(new_actioner: Actor,allow_execute: bool = false,add_to_queue: bool = false).(new_actioner,allow_execute,add_to_queue):
		allowed_execute = allow_execute
	func get_class() -> String: return "MoveTo"
	func get_display_name() -> String:
		if target:
			if target is Cell:
				return "Walking"
			return "Walking to %s" % target
		return "Walking to nowhere"
	func finish() -> void:
		if actioner.get("map"):
			actioner.get("map").update()
		.finish()
	func think() -> ThinkResult:
		if not (target is Cell):
			push_error("MoveTo needs a Cell as a target.")
			fail()
			return ThinkResult.new(STATUS.ERROR,"Error: MoveTo needs a Cell as a target")
		if (actioner.cell as Cell).get("map") != target.map: # TODO: Pathing between maps
			push_error("MoveTo between maps is unimplemented.")
			fail()
			return ThinkResult.new(STATUS.ERROR,"MoveTo between maps is unimplemented")
		if actioner.cell == target: # We're already at the destination
			finish()
			return ThinkResult.new(STATUS.DONE,"Already here")
		if actioner.astar.ready:
			# warning-ignore:unsafe_property_access
			path = actioner.astar.get_point_path(actioner.cell.point_id,target.point_id)
			if path.size() == 0:
				fail()
				return ThinkResult.new(STATUS.FAIL, "No path")
			else:
				path.remove(0)
				return ThinkResult.new(STATUS.OK)
		else:
			return ThinkResult.new(STATUS.ERROR,"ERROR: Pathfinding not ready")
	func is_actionable(tgt):
		if tgt is Actor:
			target = tgt.cell
		elif tgt is Cell:
			target = tgt
		return think()
	func execute() -> void:
		if (not path) or path.size() == 0:
			# warning-ignore:return_value_discarded
			think()
			failures.append(FAILURE.NO_PATH)
			if failures.count(FAILURE.NO_PATH) > 3:
				fail()
		if progress < 100:
			progress += 10
		else:
			var result: int = actioner.move_to(path[0])
			if result != Actor.MOVE_OK:
				# warning-ignore:return_value_discarded
				think()
			else:
				if path.size() == 1:
					status = STATUS.DONE
					finish()
				path.remove(0)
				progress = 0
