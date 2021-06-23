extends Panel

func equip_buildable(buildable) -> void:
	get_node("../../..").mousetool = buildable # @./UI/Camera2D/Player
	queue_free()
