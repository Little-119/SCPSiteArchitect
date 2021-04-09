extends Structure
class_name Lamp

var light: Light2D = Light2D.new()
var light_radius: int = 128 setget set_light_radius
var texture = ImageTexture.new()

func set_light_radius(to) -> void:
	light_radius = to
	light.texture_scale = clamp((to) / (light.texture.get_width()),1,INF)

func _init().():
	texture.create_from_image(load("res://Gfx/FullWhite.png"))
	type = "Lamp"
	character = "i"
	light.name = "Light"
	light.position = Vector2(16,16)
	light.texture = texture
	light.shadow_enabled = true
	set_light_radius(light_radius)
	add_child(light)
	
func can_coexist_with(other_thing: Thing) -> bool:
	if other_thing is Structure:
		return false
	return true
