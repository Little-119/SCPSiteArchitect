extends Node2D
class_name Thing

const theme = preload("res://Gfx/ThingTheme.tres")
const LAYER = preload("res://LayersEnum.gd")

var type := "Thing"
var uid: int = -1
# warning-ignore:unused_class_variable
var layer: float = LAYER.EMPTY
var size := Vector3.ONE

var select_priority: int = 0

export(String, FILE) var icon := "" # Can be a single character or a path to an image
export(String) var icon_fallback := "" # In case Icon is a path to an image but it fails to load
export(Color, RGB) var color: Color = Color.white

var falling: float = 0.0
var coyote_time: int = 0 # time of grace period in which Thing does not fall due to gravity
var coyote_timer: int = 0

# warning-ignore:unused_class_variable
var cell: Cell setget ,get_parent_cell
# warning-ignore:unused_class_variable
var map = null setget ,get_map

export(int) var position_z: int = 0 setget ,get_position_z # intended to be used when making maps in editor

func get_position_z() -> int:
	var parent_cell = get_parent_cell()
	if parent_cell:
		return parent_cell.cell_position.z
	else:
		return 0

func _to_string():
	return "[%s:%s]" % [type,get_instance_id()]

func get_parent_cell() -> Cell:
	if not is_inside_tree() or get_node_or_null("/root/Game") == null:
		return null
	if get_node_or_null("..") != null:
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
	var collider = StaticBody.new()
	var shape_owner = collider.create_shape_owner(Node.new())
	var shape = BoxShape.new()
	shape.extents = Vector3(1,1,1)
	collider.shape_owner_add_shape(shape_owner,shape)
	collider.name = "Collider"
	add_child(collider)

func _ready() -> void:
	if not get_map():
		return
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
					0: # don't add any icon or text. Used for walls, which are rendered elsewhere for efficiency
						pass
					1: # ASCII char icon
						label.text = icon
					_: # assume 'icon' is meant to be a path to a texture
						icon = icon.strip_edges()
						var texture = ImageTexture.new()
						var err = texture.load(icon)
						if err:
							push_error("Sprite (path: %s) for Thing %s failed to load with error code: %s." % [icon,str(self),err])
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
	if get_map():
		get_map().emit_signal("thing_removed")
	.queue_free()

func on_turn() -> void:
	pass

func force_move(to,dest_map = get_map()) -> void:
	if to is Vector3: #otherwise assume 'to' is a cell
		assert(dest_map)
		to = dest_map.get_cell(to)
	to.add_thing(self)
	gravity()

func _enter_tree():
	on_moved()

func on_moved(old_cell: Cell = null) -> void:
	if not get_parent_cell():
		return
	var new_position = get_parent_cell().cell_position
	($"Collider" as StaticBody).transform.origin = Vector3(new_position.x,new_position.z,new_position.y)

func select():
	if $"/root/Game".get("selection"):
		pass
	$"/root/Game".set("selection",self)

# warning-ignore:unused_argument
func tool_lclick_oncell(clicked_cell: Cell) -> void: # called in Map._unhanded_input()
	pass

# warning-ignore:unused_argument
func can_coexist_with(other_thing: Thing) -> bool: # check if this Thing can be on the same tile as another Thing. Used for placing, probably not for moving
	return true

# Start grammar-related
enum GRAMMATICAL_GENDER {DEFER = -1, NEUTER, PLURAL, MALE, FEMALE}
enum BIOLOGICAL_SEX {NEUTER, MALE, FEMALE, INTERSEX}
enum GENDER_IDENTITY {NONE, NONBINARY, MALE, FEMALE}

export(BIOLOGICAL_SEX) var sex: int = BIOLOGICAL_SEX.NEUTER
export(GENDER_IDENTITY) var gender_identity: int = GENDER_IDENTITY.NONE
export(GRAMMATICAL_GENDER) var gender: int = GRAMMATICAL_GENDER.DEFER

enum PRONUUN_CASE {SUBJECT,OBJECT,POSSESSIVE,REFLEXIVE}

func get_pronoun(case: int, speaker: int):
	pass
# End grammar-related

func gravity() -> void:
	if get_map():
		var support: bool = false
		for thing in (get_parent_cell() as Cell).contents:
			if thing != self and thing.get("solid"):
				support = true
		var below_cell = get_map().get_cell_or_null(get_parent_cell().cell_position + Vector3.FORWARD)
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
