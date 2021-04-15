extends SCP
class_name TrainingFox
tool

func _init().():
	type = "TrainingFox"
	character = "f"
	color = Color.orange
	has_fine_manipulation = false
	drives.append("Wander")
	needs.append(HeadpatHunger)

class NeedHeadpat extends "res://AI/Jobs/InteractWith.gd":
	func _init():
		print("headpat pls")
		name = "NeedHeadpat"
	
	func on_done(actor):
		get_parent().needs_dict["HeadpatHonger"].honger = 0
		queue_free()

class HeadpatHunger extends Need:
	var honger = 20
	var job = null
	func _init():
		type = "HeadpatHonger"
	func on_life_process():
		honger += 1
	func on_ai_process():
		if honger > 50:
			job = actor.emit_job(NeedHeadpat)
		elif job:
			job.queue_free()
