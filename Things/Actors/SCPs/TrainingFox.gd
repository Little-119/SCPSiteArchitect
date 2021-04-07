extends SCP
class_name TrainingFox

func _init().():
	type = "TrainingFox"
	icon = "f"
	color = Color.orange
	has_fine_manipulation = false
	drives.append("Wander")
