extends "res://UI/PopupMenus/PopupMenu.gd"

func _on_BackButton_pressed():
	($"/root/Game/Player/Camera2D/UI" as Control).add_child((load("res://UI/PopupMenus/PauseMenu.tscn") as PackedScene).instance())
	queue_free()

func _on_CloseButton_pressed():
	queue_free()
