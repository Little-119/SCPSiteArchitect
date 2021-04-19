extends "res://UI/PopupMenu.gd"

func _on_ResumeButton_pressed():
	queue_free()

func _on_QuitButton_pressed():
	get_tree().quit(0)

func _on_OptionsButton_pressed():
	($".." as Control).add_child((load("res://UI/Options/OptionsMenu.tscn") as PackedScene).instance())
	queue_free()

func _on_NewGameButton_second_pressed():
	$"/root/Game".current_universe.queue_free()
	var new_universe: Universe = $"/root/Game".setup_universe(false)
	var map = Map.new(Vector3(16,16,1))
	new_universe.add_child(map)
	new_universe.set_current_map(map)
	($"/root/Game/Player/Camera2D" as Camera2D).position = Vector2.ZERO
	$"/root/Game".current_universe = new_universe
	new_universe.turn_timer.start()
	queue_free()
