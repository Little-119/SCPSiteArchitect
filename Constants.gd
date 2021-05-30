extends Node
# warning-ignore-all:unused_class_variable
# Contains global constants to be accessed by other scripts

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

const turn_length: float = 0.1 # length of a turn in seconds

onready var default_cell: Cell = (load("res://DefaultCell.tscn") as PackedScene).instance()
