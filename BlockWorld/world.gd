extends Node

var lib = preload("res://lib.gd")

func _ready():
	lib.spawnBlock(get_tree().root.get_node("world"), (Vector3) (0, 0, 0))
