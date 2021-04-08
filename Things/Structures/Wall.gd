extends Structure
class_name Wall

func _init().() -> void:
	type = "Wall"
	icon = ""
	var occluder = LightOccluder2D.new()
	occluder.occluder = OccluderPolygon2D.new()
	occluder.occluder.polygon = PoolVector2Array([Vector2.ZERO,Vector2(32,0),Vector2(32,32),Vector2(0,32)])
	add_child(occluder)

func tool_lclick_oncell(cell: Cell, event: InputEvent) -> void:
	.tool_lclick_oncell(cell, event)
	pass

func _draw():
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE * ProjectSettings.get_setting("Game/cell_size")),color)

func can_coexist_with(other_thing: Thing) -> bool:
	if other_thing is Structure:
		return false
	return true
