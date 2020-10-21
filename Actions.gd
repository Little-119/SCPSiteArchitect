extends Node

class BaseAction:
	extends Node
	var actioner: Actor
	var target
	var path
	var progress: int = 0
	func _init(new_actioner: Actor) -> void:
		actioner = new_actioner
		actioner.actions.append(self)
		actioner.add_child(self)
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
		pass
	func think():
		if actioner.astar.ready:
			path = actioner.astar.get_point_path(actioner.cell.point_id,actioner.map.get_cell(Vector3(15,15,0)).point_id)
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
