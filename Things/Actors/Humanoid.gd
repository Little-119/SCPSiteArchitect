extends Actor
class_name Humanoid
tool
# Human or human-ish actors, with names and such

export(String) var first_name: String = ""
export(String) var last_name: String = ""
export(String) var nick_name: String = ""
export(String) var alias: String = "" # e.g. D-class designations
export(String) var culture: String = "American"

func _to_string():
	return "[%s (Name: '%s'):%s]" % [type,get_display_name(),get_instance_id()]

func get_display_name() -> String:
	if alias.length() > 0:
		return alias
	else:
		if nick_name.length() > 0:
			return ("%s '%s' %s" % [first_name, nick_name, last_name])
		else:
			return ("%s %s" % [first_name, last_name])

static func generate_name(gender: int,from_culture: String) -> PoolStringArray:
	return PoolStringArray(["Bong","Bong","Bong Bong"])

func _init():
	type = "Humanoid"
	needs.append("Hunger")
	drives.append("Work")
	drives.append("Wander")
	var new_name = generate_name(gender, culture)
	first_name = new_name[0]
	last_name = new_name[1]
	nick_name = new_name[2]
