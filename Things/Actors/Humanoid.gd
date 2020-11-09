extends Actor
class_name Humanoid

var first_name: String = "FirstName"
var last_name: String = "LastName"
var nick_name: String = ""
var alias: String = "" # e.g. D-class designations
var culture: String = "American"

func _to_string():
	return "[%s (Name: %s):%s]" % [type,get_display_name(),get_instance_id()]

func get_full_name() -> String:
	return "%s %s" % [first_name, last_name]

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
