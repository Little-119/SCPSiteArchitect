extends Node
# warning-ignore-all:unused_class_variable
# Contains global variables to be accessed by other scripts

var cell_size: int = 32 # Width/height of cells, in pixels

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

const turn_length: float = 0.1 # length of a turn in seconds

onready var default_cell: Cell = (load("res://DefaultCell.tscn") as PackedScene).instance()
