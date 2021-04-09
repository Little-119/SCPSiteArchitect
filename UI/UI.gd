extends Control

func update_size() -> void:
	rect_size = ($"/root" as Viewport).size
	rect_position = ($"/root" as Viewport).size / -2

func _ready():
	update_size()
	# warning-ignore:return_value_discarded
	$"/root".connect("size_changed",self,"update_size")

func _process(_delta) -> void:
	update()

func _on_mainbutton_pressed(button_name: String) -> void:
	match button_name:
		"Architect":
			if has_node("ArchitectPanel"):
				$"ArchitectPanel".queue_free()
			else:
				# warning-ignore:return_value_discarded
				add_child((load("res://UI/ArchitectPanel.tscn") as PackedScene).instance())
