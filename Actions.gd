extends Node

enum STATUS {OK,NEW,DONE=4,FAIL,ERROR}

class ThinkResult extends Reference:
	var code: int = STATUS.NEW
	var details: String = "Generic reason"
	func _init(c: int = STATUS.NEW,d: String = details):
		code = c
		details = d

class BaseAction extends Node:
	signal finished
	# warning-ignore:unused_class_variable
	var type: String setget ,get_class
	func get_class() -> String: return "BaseAction"
	# warning-ignore:unused_class_variable
	var status: int = STATUS.NEW
	var last_think_result: ThinkResult = null
	var allowed_execute: bool = true # checked in Actor.gd before calling execute
	var actioner: Actor
	# warning-ignore:unused_class_variable
	var target = null setget set_target
	func set_target(new_target) -> void:
		target = new_target
		if get_node_or_null("/root/Game/Player") and actioner in $"/root/Game/Player:selection":
			$"/root/Game/Player".call("update_selection_card")
	func is_debug_mode() -> bool: # checks if this action is part of automated testing
		return get_path().get_name(2) == "DebugContainer"
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
		if get_node_or_null("/root/Game/Player") and (actioner in $"/root/Game/Player:selection") and allow_execute:
			$"/root/Game/Player".call("update_selection_box")
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
	func think_result(result_status: int,error_message: String = "") -> ThinkResult:
		var result = ThinkResult.new(result_status,error_message)
		last_think_result = result
		match result_status:
			STATUS.FAIL,STATUS.ERROR:
				if not is_debug_mode():
					push_error(error_message)
				fail()
		return result
	func execute() -> void:
		pass
	func finish() -> void:
		emit_signal("finished")
		if get_node_or_null("/root/Game/Player") and actioner in $"/root/Game/Player".get("selection"):
			$"/root/Game/Player".call("update_selection_card")
		if not is_debug_mode(): # automated tests need actions to stick around to check their result
			queue_free()
	func fail() -> void:
		finish()
	func is_actionable(_tgt) -> bool:
		return true

class MoveTo extends BaseAction: # Move between cells on one map
	var move_turns: int = 10
	func _init(new_actioner: Actor,allow_execute: bool = false,add_to_queue: bool = false).(new_actioner,allow_execute,add_to_queue):
		allowed_execute = allow_execute
	func set_target(new_target) -> void:
		if new_target is Vector3:
			push_warning("MoveTo should be given a cell as a target")
			if actioner.get("map"):
				new_target = actioner.get("map").get_cell(new_target)
		if new_target is Cell:
			if new_target.is_default_cell:
				fail()
				# warning-ignore:return_value_discarded
				think_result(STATUS.ERROR,"Error: MoveTo needs a non-default Cell as a target")
				return
		else:
			fail()
			# warning-ignore:return_value_discarded
			think_result(STATUS.ERROR,"Error: MoveTo needs a Cell as a target")
			return
		.set_target(new_target)
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
		if not target or status == STATUS.FAIL or status == STATUS.ERROR:
			return last_think_result
		if actioner.cell == target: # We're already at the destination
			finish()
			return think_result(STATUS.DONE,"Already at destination")
		if actioner.astar.ready:
			# warning-ignore:unsafe_property_access
			path = actioner.astar.get_point_path(actioner.cell.point_id,target.point_id)
			if path.size() == 0:
				return think_result(STATUS.OK, "No path")
			else:
				path.remove(0)
				return think_result(STATUS.OK)
		else:
			return think_result(STATUS.ERROR,"Error: Pathfinding not ready")
	func is_actionable(tgt):
		if tgt is Actor:
			target = tgt.cell
		elif tgt is Cell:
			target = tgt
		return think()
	func execute() -> void:
		if (not path) or path.size() == 0:
			var result = think()
			if result.details == "No path":
				failures.append(FAILURE.NO_PATH)
				if failures.count(FAILURE.NO_PATH) > 3:
					# warning-ignore:return_value_discarded
					think_result(STATUS.FAIL,"No path")
				return
			if result.code != STATUS.OK:
				return
		if move_turns != 0 and progress < move_turns:
			progress += 1
		else:
			var result: int = actioner.move_to(path[0])
			if result != Actor.MOVE_OK:
				# warning-ignore:return_value_discarded
				think()
			else:
				if path.size() == 1:
					status = STATUS.DONE
					# warning-ignore:return_value_discarded
					think_result(STATUS.DONE,"")
				path.remove(0)
				progress = 0
