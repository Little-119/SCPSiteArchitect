extends Node # Making this Object or Reference causes opcode #12 internal script error
# see AI/AI DOCUMENTATION.txt for documentation on this

enum {NO_EXECUTE=-1,DO_NOW,ADD_TO_QUEUE}
enum STATUS {OK,NEW,DONE=4,FAIL,ERROR}

class ThinkResult extends Reference: # Contains data on the result of an action's think()
	var code: int = STATUS.NEW # status code
	var details: String = "Generic reason" # contains message detailing status
	func _init(c: int = STATUS.NEW,d: String = details):
		code = c
		details = d

class BaseAction extends Node:
	signal finished
	# warning-ignore:unused_class_variable
	var type: String setget ,get_class
	func get_class() -> String: return "BaseAction"
	# warning-ignore:unused_class_variable
	var status: int = STATUS.NEW # status code
	var last_think_result: ThinkResult = null
	var allowed_execute: bool = true # checked in Actor.gd before calling execute
	var actioner: Actor # Actor acting this action
	# warning-ignore:unused_class_variable
	var driver # Drive that created this action
	var forced: bool = false # Whether player is making the actor perform this action
	var subaction # Nested action. Processed instead of this action until it's finished
	# warning-ignore:unused_class_variable
	var target = null setget set_target
	func set_target(new_target) -> void:
		target = new_target
		if target is Thing:
			target.set("reserved_in",self)
		if is_inside_tree():
			if get_node_or_null("/root/Game/Player") and actioner in $"/root/Game/Player".get("selection"):
				$"/root/Game/Player".call("update_selection_card")
	func is_debug_mode() -> bool: # checks if this action is part of automated testing
		return get_path().get_name(2) == "DebugContainer"
	# warning-ignore:unused_class_variable
	var path: PoolVector3Array # Path to target, if needed
	# warning-ignore:unused_class_variable
	var progress: int = 0 # Some actions take time, this is used to track that
	enum FAILURE {NO_PATH}
	# warning-ignore:unused_class_variable
	var failures: Array = []
	func _init(parent: Node = null,behavior: int = DO_NOW,force: bool = false) -> void:
		allowed_execute = behavior != NO_EXECUTE
		forced = force
		parent.call_deferred("add_child",self,true)
		if parent is Actor:
			actioner = parent
		else:
			actioner = (parent as BaseAction).actioner
			# warning-ignore:unsafe_property_access
			(parent as BaseAction).subaction = self
			return
		match behavior:
			NO_EXECUTE:
				allowed_execute = false
			ADD_TO_QUEUE:
				actioner.actions.append(self)
			DO_NOW:
				actioner.actions.clear()
				actioner.actions.insert(0,self)
		
		if is_inside_tree():
			if get_node_or_null("/root/Game/Player") and (actioner in $"/root/Game/Player".get("selection")) and allowed_execute:
				if actioner.get("map"):
					actioner.get("map").update() # for drawing path lines, etc
	func process() -> void:
		if subaction:
			subaction.process()
		else:
			execute()
	func _to_string() -> String:
		var text: String = "[%s:%s (Owner: %s)]" % [get_class(),get_instance_id(),actioner]
		if not allowed_execute:
			text += " (nonexecutable)"
		return text
	func get_display_name() -> String: # name to be displayed to the player
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
		if is_inside_tree():
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
	func _init(parent: Node = null,behavior: int = DO_NOW,force: bool = false).(parent,behavior,force) -> void:
		pass
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

class TakeItem extends BaseAction:
	func get_class() -> String: return "TakeItem"
	func _init(parent: Node = null,behavior: int = DO_NOW,force: bool = false).(parent,behavior,force) -> void:
		pass
	func think() -> ThinkResult:
		var target_parent = target.get_parent()
		if target_parent == actioner:
			finish()
			return think_result(STATUS.DONE,"Item in inventory")
		elif target_parent is Cell:
			return think_result(STATUS.OK)
		else:
			return think_result(STATUS.FAIL)
	func execute() -> void:
		var target_parent = target.get_parent()
		if target_parent == actioner.get_parent():
			actioner.call_deferred("add_child",target)
			finish()
		elif target_parent != actioner:
			if not subaction:
				subaction = MoveTo.new(self,DO_NOW,forced)
				subaction.target = target.get_parent()

class UseItem extends BaseAction:
	func get_class() -> String: return "UseItem"
	func _init(parent: Node = null,behavior: int = DO_NOW,force: bool = false).(parent,behavior,force) -> void:
		pass
	func execute() -> void:
		if target.get_parent() == actioner:
			if progress >= target.use_time:
				target.use(actioner)
				finish()
				return
			progress += 1
		else:
			if not subaction:
				subaction = TakeItem.new(self,DO_NOW,forced)
				subaction.target = target
