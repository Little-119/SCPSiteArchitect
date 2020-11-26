extends Reference
class_name Time

var seconds: int = 0

enum {SECOND,MINUTE,HOUR,DAY,WEEK,SEASON,YEAR}

func get_seconds_in(section:int=SECOND) -> int:
	var denominator: int = 1
	match section:
		SECOND: pass
		MINUTE: denominator = 1
		HOUR: denominator = 60
		DAY: denominator = 60 * 24
		WEEK: denominator = 60 * 24 * 7 
		SEASON: denominator = 60 * 24 * 7 * 2
		YEAR: denominator = 60 * 24 * 7 * 2 * 4
	return denominator

func get_total(section:int=SECOND,s:int=seconds) -> int:
	# warning-ignore:integer_division
	return s / get_seconds_in(section)

func get_all(s:int=seconds) -> Dictionary:
	var S: int = s
	return {seconds = S}
