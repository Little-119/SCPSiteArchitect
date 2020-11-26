extends Node
# warning-ignore-all:unused_class_variable

var cell_size: int = 32 # Width/height of cells, in pixels

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

const turn_length: float = 0.1 # length of a turn in seconds

var default_cell: Cell
func _ready():
	default_cell = (load("res://DefaultCell.tscn") as PackedScene).instance()
