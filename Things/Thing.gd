extends Node2D
class_name Thing

const theme = preload("res://Gfx/ThingTheme.tres")
const LAYER = preload("res://LayersEnum.gd")

var type := "Thing"
var uid: int = -1
# warning-ignore:unused_class_variable
var layer: float = LAYER.EMPTY
var size := Vector3.ONE

var icon := "" # Can be a single character or a path to an image
var icon_fallback := "" # In case Icon is a path to an image but it fails to load
var color: Color = Color.white

var falling: float = 0.0
var coyote_time: int = 0 # time of grace period in which Thing does not fall due to gravity
var coyote_timer: int = 0

var cell: Cell setget ,get_parent_cell
var map = null setget ,get_map

func get_parent_cell() -> Cell:
	if $".." != null:
		return ($".." as Cell)
	else:
		# warning-ignore:unsafe_property_access
		return $"/root/Game".default_cell

func get_map():
	var parent_cell = get_parent_cell()
	if parent_cell:
		return parent_cell.map
	else:
		return null

func _init() -> void:
	pass

func _ready() -> void:
	name = type
	z_index += 1
	uid = ThingsManager.next_thing_uid
	ThingsManager.next_thing_uid += 1
	var sprite = Sprite.new()
	sprite.name = "Sprite"
	sprite.position = Vector2(16,16)
	sprite.visible = true
	var label := Label.new()
	label.name = "Label"
	label.rect_min_size = Vector2(32,32)
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.mouse_filter = Label.MOUSE_FILTER_IGNORE
	label.theme = theme
	label.add_color_override("font_color",color)
	
	add_child(label)
	add_child(sprite)
	if icon is String:
		match icon:
			" ":
				icon = ""
				continue
			_:
				match len(icon):
					0:
						pass
					1:
						label.text = icon
					_:
						icon = icon.strip_edges()
						var texture = ImageTexture.new()
						var err = texture.load(icon)
						if err:
							print("Sprite (path: %s) for Thing %s failed to load with error code: %s" % [icon,name,err])
							if len(icon_fallback.strip_edges()) > 0:
								label.text = icon_fallback
							else:
								label.text = "?"
						else:
							sprite.texture = texture
							var s = (Vector2.ONE * Constants.cell_size)/sprite.texture.get_size()
							sprite.scale = s
	# warning-ignore:return_value_discarded
	$"/root/Game/TurnTimer".connect("timeout",self,"on_turn")

func queue_free() -> void:
	var map = get_map()
	if map:
		map.emit_signal("thing_removed")
	.queue_free()

func on_turn() -> void:
	pass

func force_move(to,map = get_map()) -> void:
	if to is Vector3: #otherwise assume 'to' is a cell
		assert(map)
		to = map.get_cell(to)
	to.add_thing(self)
	gravity()

# warning-ignore:unused_argument
func tool_lclick_oncell(clicked_cell: Cell) -> void: # called in Map._unhanded_input()
	pass

# warning-ignore:unused_argument
func can_coexist_with(other_thing: Thing) -> bool: # check if this Thing can be on the same tile as another Thing. Used for placing, probably not for moving
	return true

func gravity() -> void:
	var map = get_map()
	if map:
		var support: bool = false
		for thing in (get_parent_cell() as Cell).contents:
			if thing != self and thing.get("solid"):
				support = true
		var below_cell = map.get_cell_or_null(get_parent_cell().cell_position + Vector3.FORWARD)
		if not below_cell:
			support = true
		else:
			for thing in below_cell.contents:
				if thing.solid:
					support = true
				#if thing is Structure:
				#	return # we have support below, no fall
		if not support:
			falling += 1
			force_move(below_cell)
		else:
			if falling > 0:
				if coyote_timer < coyote_time:
					coyote_timer += 1
				else:
					print(falling)
					splat()
					falling = 0
					coyote_timer = 0

func splat() -> void:
	pass
