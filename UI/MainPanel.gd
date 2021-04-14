extends Panel

func equip_buildable(button,buildable) -> void:
	button.get_node("../../../..").mousetool = buildable # @./ArchitectPanel/UI/Camera2D/Player
	queue_free()
