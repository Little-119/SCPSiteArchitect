extends Actor
class_name TestActor

func _init().():
	type = "TestActor"

func _ready():
	if not get_map():
		return
	#var act = Actions.MoveTo.new(self)
	#act.target = get_map().get_cell(Vector3(15,15,0))
	#act.think()
	#act.execute()
