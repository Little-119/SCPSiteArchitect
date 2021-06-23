extends Node
# warning-ignore-all:unused_class_variable
# Contains global constants to be accessed by other scripts

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

onready var default_cell: Cell = (load("res://DefaultCell.tscn") as PackedScene).instance()
