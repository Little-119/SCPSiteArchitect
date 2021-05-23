extends Thing
class_name Structure
tool
# Structures are structures like walls and furniture

enum CONSTRUCTION_STAGES {COMPLETE,WIP,BLUEPRINT}
export(CONSTRUCTION_STAGES) var construction_state: int = CONSTRUCTION_STAGES.COMPLETE setget set_construction_state

func get_display_name() -> String:
	var suffix: String = ""
	match CONSTRUCTION_STAGES:
		CONSTRUCTION_STAGES.WIP:
			suffix = " (constructing)"
		CONSTRUCTION_STAGES.BLUEPRINT:
			suffix = " (blueprint)"
	return .get_display_name() + suffix

func _init().():
	type = "Structure"
	layer = LAYER.STRUCTURE
	select_priority = 1

func tool_lclick_oncell(cell: Cell, event: InputEvent) -> void:
	.tool_lclick_oncell(cell, event)
	var valid: bool = true
	for other_thing in cell.contents:
		if not can_coexist_with(other_thing):
			valid = false
			break
	if valid:
		var new_thing: Structure = (get_script() as GDScript).new()
		new_thing.construction_state = CONSTRUCTION_STAGES.BLUEPRINT
		cell.add_thing(new_thing)

func set_construction_state(value: int) -> void:
	assert(value >= 0 and value <= 2,"Value out of range")
	if construction_state == value:
		return
	match value: # check new state, then check current state
		CONSTRUCTION_STAGES.BLUEPRINT:
			emit_job(Construct)
			match construction_state:
				CONSTRUCTION_STAGES.COMPLETE: # complete-to-blueprint. Usually called when placed by player
					set_meta("unblueprinted_color",color)
					set_color(Color(0,.75,1,.5))
		
		CONSTRUCTION_STAGES.WIP:
			match construction_state:
				CONSTRUCTION_STAGES.BLUEPRINT: # blueprint-to-wip. First stage of construction
					set_meta("unwip_color",get_meta("unblueprinted_color"))
					remove_meta("unblueprinted_color")
					set_color((get_meta("unwip_color") as Color).darkened(.3))
		
		CONSTRUCTION_STAGES.COMPLETE:
			match construction_state:
				CONSTRUCTION_STAGES.WIP: # wip-to-complete. Second and final stage of construction
					set_color(get_meta("unwip_color"))
					remove_meta("unwip_color")
				CONSTRUCTION_STAGES.BLUEPRINT: # blueprint-to-complete
					set_color(get_meta("unblueprinted_color"))
					remove_meta("unblueprinted_color")
	if get_map():
		get_map().emit_signal("on_thing_added")
	construction_state = value

class Construct extends "res://AI/Jobs/InteractWith.gd":
	func on_done(actor):
		get_parent().construction_state = CONSTRUCTION_STAGES.COMPLETE
		.on_done(actor)
