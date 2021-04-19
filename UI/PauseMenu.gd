extends "res://UI/PopupMenu.gd"

func _on_ResumeButton_pressed():
	queue_free()

func _on_QuitButton_pressed():
	get_tree().quit(0)

func _on_OptionsButton_pressed():
	($".." as Control).add_child((load("res://UI/Options/OptionsMenu.tscn") as PackedScene).instance())
	queue_free()
