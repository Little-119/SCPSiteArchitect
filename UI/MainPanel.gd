extends Panel

var panel_size: Vector2 = Vector2(64,64)

func resize() -> void:
	margin_top = margin_bottom - panel_size.y
	margin_right = margin_left + panel_size.x

func _ready() -> void:
	resize()

func equip_buildable(button,buildable) -> void:
	button.get_node("../../../..").mousetool = buildable # @./ArchitectPanel/UI/Camera2D/Player
	queue_free()
