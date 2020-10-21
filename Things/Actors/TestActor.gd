extends Actor
class_name TestActor

func _init():
	type = "TestActor"

func _ready():
	var act = Actions.MoveTo.new(self)
	act.think()
	act.execute()
