extends Panel

func equip_buildable(button,buildable) -> void:
	get_node("../../..").mousetool = buildable # @./UI/Camera2D/Player
	queue_free()
