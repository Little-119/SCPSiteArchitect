extends Panel

func equip_mousetool(mousetool) -> void:
	get_node("../../..").mousetool = mousetool # @./UI/Camera2D/Player
	queue_free()
