extends "res://UI/PopupMenus/PopupMenu.gd"

func _on_ResumeButton_pressed():
	queue_free()

func _on_QuitButton_pressed():
	get_tree().quit(0)

func _on_OptionsButton_pressed():
	($".." as Control).add_child((load("res://UI/PopupMenus/Options/OptionsMenu.tscn") as PackedScene).instance())
	queue_free()

func _on_NewGameButton_second_pressed():
	# warning-ignore:unsafe_method_access
	$"/root/Game".new_game()
	queue_free()
