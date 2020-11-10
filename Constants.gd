extends Node
# warning-ignore-all:unused_class_variable

var cell_size: int = 32 # Width/height of cells, in pixels

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

var default_cell

func _ready():
	default_cell = load("res://DefaultCell.tscn").instance()
