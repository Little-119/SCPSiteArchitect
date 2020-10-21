extends Actor
class_name TestActor

func _init():
	type = "TestActor"

func _ready():
	var act = Actions.MoveTo.new(self)
	act.target = Vector3(15,15,0)
	act.think()
	act.execute()
