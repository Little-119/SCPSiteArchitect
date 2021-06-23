extends Node2D
class_name Thing
tool
# Things encompass things, things which usually exist inside of cells. Things include structures, turfs, items, and mobs.

const theme = preload("res://Gfx/ThingTheme.tres")
const LAYER = preload("res://LayersEnum.gd")

var type := "Thing"

var uid: int = -1
# warning-ignore:unused_class_variable
var layer: float = LAYER.EMPTY

# warning-ignore:unused_class_variable
var select_priority: int = 0 # used in Cell.gd

export(String, FILE) var icon: String = "" setget set_icon
export(String) var character: String = "" setget set_character
export(Color, RGB) var color: Color = Color.white setget set_color

var falling: float = 0.0
var coyote_time: int = 0 # time of grace period in which Thing does not fall due to gravity
var coyote_timer: int = 0

# warning-ignore:unused_class_variable
var solid = true

# warning-ignore:unused_class_variable
var cell: Cell setget ,get_parent_cell # convenience variable
# warning-ignore:unused_class_variable
var map = null setget ,get_map # convenience variable

# warning-ignore:unused_class_variable
export(int,0,0xFF) var position_z: int = 0 setget ,get_position_z # Z component of position. Intended to be used when making maps in editor

var reserved_in # when this Thing is reserved for use by an Actor, the Action is stored here

var designators: Array = [] # can be made up of strings and References defined in Designators.gd

func get_position_z() -> int:
	var parent_cell = get_parent_cell()
	if parent_cell:
		return parent_cell.cell_position.z
	else:
		return 0

func _to_string():
	return "[%s:%s]" % [type,get_instance_id()]

func get_parent_cell() -> Cell:
	if get_node_or_null("..") != null:
		return ($".." as Cell)
	else:
		return Constants.get("default_cell")

func get_map():
	var parent_cell = get_parent_cell()
	return parent_cell.map if parent_cell and not parent_cell.is_default_cell else null

func get_relative(where: String,path_from_there: String): # helper function for the below three functions.
	# 'where' should be the name of a method that returns a node
	assert(has_method(where),"get_relative called without valid method name.")
	var there = call(where)
	assert((there == null) or (there is Node),"Method passed to get_relative returned unexpected result.")
	if not there:
		return null
	else:
		return there.get_node_or_null(path_from_there)

func get_universe():
	return get_relative("get_map","..")

func get_game():
	return get_relative("get_universe","..")

func get_player():
	return get_relative("get_game","Player")

func get_meta_or_null(key: String): # get_meta but defaults to null instead of erroring
	return get_meta(key) if has_meta(key) else null

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
	create_sprite()

func copy() -> Thing: # Makes a new Thing of this Thing's class
	return (get_script() as GDScript).new()

func create_sprite() -> void:
	var label: Label = get_node_or_null("Label")
	if not label:
		label = Label.new()
		label.name = "Label"
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.mouse_filter = Label.MOUSE_FILTER_IGNORE
		label.theme = theme
		label.rect_size = Vector2.ONE * ProjectSettings.get_setting("Game/cell_size")
		label.rect_pivot_offset = label.rect_size * .5
		label.rect_scale = label.rect_size / 32
		add_child(label)
	label.text = character
	label.add_color_override("font_color",color)
	if not icon.empty() and icon.begins_with("res://"):
		var texture = ImageTexture.new()
		var err = texture.load(icon)
		if err:
			push_error("Sprite (path: %s) for Thing %s failed to load with error code: %s." % [icon,str(self),err])
			if get_node_or_null("Sprite"):
				($"Sprite" as Sprite).texture = null
		else:
			var sprite = get_node_or_null("Sprite")
			if not sprite:
				sprite = Sprite.new()
				sprite.name = "Sprite"
				sprite.visible = true
				sprite.scale = (Vector2.ONE * ProjectSettings.get_setting("Game/cell_size"))/texture.get_size()
				sprite.position = Vector2.ONE * .5 * ProjectSettings.get_setting("Game/cell_size")
				label.add_child(sprite)
			sprite.texture = texture

func set_color(value: Color):
	if color == value:
		return
	color = value
	create_sprite()

func set_icon(value: String):
	if icon == value:
		return
	icon = value
	create_sprite()

func set_character(value: String):
	if character == value:
		return
	character = value
	create_sprite()

func _draw():
	if get_node_or_null("/root/Game/Player") and self in $"/root/Game/Player".get("selection"):
		draw_rect(Rect2(0,0,ProjectSettings.get_setting("Game/cell_size"),ProjectSettings.get_setting("Game/cell_size")),Color.white,false,2)

func queue_free() -> void:
	if not is_inside_tree():
		.queue_free()
		return
	if get_map():
		get_map().emit_signal("thing_removed")
	if get_node_or_null("/root/Game/Player") and self in $"/root/Game/Player".selection:
		# warning-ignore:unsafe_property_access
		var selection: Array = $"/root/Game/Player".rawget_selection()
		for i in selection.size():
			var thing_ref = selection[i]
			if thing_ref.get_ref() == self:
				selection.remove(i)
				break
		$"/root/Game/Player".update_selection_card()
	if get_parent_cell():
		get_parent_cell().remove_child(self)
	.queue_free()

func on_turn() -> void:
	pass

func force_move(to,dest_map = get_map()) -> void:
	if to is Vector3: #otherwise assume 'to' is a cell
		assert(dest_map)
		to = dest_map.get_cell(to)
	to.call_deferred("add_thing",self)
	gravity()

func _enter_tree() -> void:
	on_moved()

var icon_offset: Vector2 = Vector2.ZERO setget set_icon_offset

func set_icon_offset(value: Vector2):
	icon_offset = value
	($"Label" as Label).rect_position = value

class IconLerper extends Node:
	var start: Vector2 = Vector2.ZERO
	var end: Vector2 = Vector2.ZERO
	var t: float = 0.0
	func _notification(what):
		if what == NOTIFICATION_PARENTED:
			update()
	func update() -> void:
		var universe = get_parent().get_universe()
		if not universe.turn_timer.paused:
			t += .05 * (.1 / universe.turn_timer.wait_time)
		if t > 1:
			($".." as Thing).set_icon_offset(Vector2.ZERO)
			queue_free()
		else:
			($".." as Thing).set_icon_offset(start.linear_interpolate(end,t) * ProjectSettings.get_setting("Game/cell_size"))
	func _process(_delta: float) -> void:
		update()

func on_moved(old_cell: Cell = null) -> void:
	if not get_parent_cell():
		return
	var new_position = get_parent_cell().cell_position
	if old_cell:
		var old_position = old_cell.cell_position
		var position_difference = (new_position - old_position)
		if abs(position_difference.x) <= 1 and abs(position_difference.y) <= 1:
			var lerper: IconLerper = IconLerper.new()
			lerper.start = Vector2(position_difference.x,position_difference.y) * -1
			add_child(lerper)
	($"Collider" as StaticBody).transform.origin = Vector3(new_position.x,new_position.z,new_position.y)

func tool_lclick_oncell(clicked_cell: Cell, event: InputEvent) -> void: # called in Map._unhanded_input()
	pass

func can_coexist_with(_other_thing: Thing) -> bool: # check if this Thing can be on the same tile as another Thing. Used for placing, probably not for moving
	return true

func can_exist_on(cell: Cell) -> bool: # Checks if there's anything this Thing can't coexist with on a tile
	for other_thing in cell.contents:
		if not can_coexist_with(other_thing):
			return false
	return true

func find_things_custom(filter_func_holder, filter_func_name, filter_args) -> Array:
	var found: Array = []
	if not get_map():
		push_error("Tried to find things of type when not in a map")
		return found
	for cell1 in get_map().cells:
		for thing in cell1.contents:
			if thing == self:
				continue
			if filter_func_holder.callv(filter_func_name,[thing] + filter_args):
				found.append(thing)
	return found

static func func_is(thing, script): # helper function for below
	return thing is script

static func func_is_and_unreserved(thing,script,exclude):
	if exclude:
		return thing is script and thing.get("reserved_in") != exclude
	else:
		return thing is script and thing.get("reserved_in") == null

func find_things_of_type(search_for: GDScript) -> Array:
	return find_things_custom(self,"func_is",[search_for])

func sort_cells_by_distance(a: Cell, b: Cell) -> bool:
	var parent_cell_pos = get_parent_cell().cell_position
	return parent_cell_pos.distance_squared_to(a.cell_position) < parent_cell_pos.distance_squared_to(b.cell_position)

func sort_things_by_distance(a: Thing,b: Thing) -> bool:
	var parent_cell_pos = get_parent_cell().cell_position
	return parent_cell_pos.distance_squared_to(a.cell.cell_position) < parent_cell_pos.distance_squared_to(b.cell.cell_position)

func sort_jobs_by_distance(a: Job, b: Job):
	return sort_things_by_distance(a.get_parent(),b.get_parent())

func find_things_in_self(filter_func_holder, filter_func_name, filter_args) -> Array:
	var found: Array = []
	for node in get_children():
		if filter_func_holder.callv(filter_func_name,[node] + filter_args):
			found.append(node)
	return found

func find_closest_thing_of_type(search_for: GDScript, search_self: bool = false, ignore_reserved: bool = false):
	var found_things = find_things_of_type(search_for) if not ignore_reserved else find_things_custom(self,"func_is_and_unreserved",[search_for,self])
	if found_things.size() > 1:
		found_things.sort_custom(self,"sort_things_by_distance")
	if search_self:
		found_things = find_things_in_self(self,"func_is",[search_for]) + found_things
	if found_things.empty():
		return null
	
	return found_things.front()

func is_adjacent(other: Thing) -> bool:
	if get_map() != other.map:
		return false
	return get_parent_cell().cell_position.distance_squared_to(other.cell.cell_position) <= 2

func emit_job(job: GDScript) -> Node:
	for c in get_children():
		if c is job:
			return null
	var new_job = job.new()
	call_deferred("add_child",new_job,true)
	return new_job

# Start grammar-related

func get_display_name() -> String:
	return type

enum GRAMMATICAL_GENDER {DEFER = -1, NEUTER, PLURAL, MALE, FEMALE}
enum BIOLOGICAL_SEX {NEUTER, MALE, FEMALE, INTERSEX}
enum GENDER_IDENTITY {NONE, NONBINARY, MALE, FEMALE}

# warning-ignore:unused_class_variable
export(BIOLOGICAL_SEX) var bio_sex: int = BIOLOGICAL_SEX.NEUTER
# warning-ignore:unused_class_variable
export(GENDER_IDENTITY) var gender_identity: int = GENDER_IDENTITY.NONE
# warning-ignore:unused_class_variable
export(GRAMMATICAL_GENDER) var gender: int = GRAMMATICAL_GENDER.DEFER

enum PRONOUN_CASE {SUBJECT,OBJECT,POSSESSIVE,REFLEXIVE}

func get_pronoun(case: int, speaker: int) -> String:
	return ""

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
			below_cell.call_deferred("add_thing",self) # this is used intead of force_move to avoid a stack overflow
		else:
			if falling > 0:
				if coyote_timer < coyote_time:
					coyote_timer += 1
				else:
					splat()
					falling = 0
					coyote_timer = 0

func splat() -> void:
	pass

func add_designator(designator) -> void: # can be string or object
	assert(not ((designator.name if designator is Object else designator) in designators)) # check for duplicate
	designators.append(designator)
	if self in $"/root/Game/Player".selection:
		$"/root/Game/Player".update_selection_card()

func remove_designator(designator_to_remove) -> void: # can be string or object
	var designator_to_remove_name = designator_to_remove.name if designator_to_remove is Object else designator_to_remove
	for i in designators.size():
		var designator = designators[i]
		if (designator.name if designator is Object else designator) == designator_to_remove_name:
			designators[i] = null
	designators.erase(null)
	if self in $"/root/Game/Player".selection:
		$"/root/Game/Player".update_selection_card()

func _on_designate(designator):
	pass

func toggle_forbidden() -> void: # not everything should be forbiddable, but multiple descendants of Thing use this code (Door and Item)
	var new_state = not (get_meta("forbidden") if has_meta("forbidden") else false)
	set_meta("forbidden",new_state)
	if new_state:
		$"Label".add_child(load("res://ForbidOverlay.tscn").instance(),true)
	else:
		$"Label/ForbidOverlay".queue_free()
	
