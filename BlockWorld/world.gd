extends Node

var lib = preload("res://lib.gd")

func _ready():
	for ix in range(-128, 128):
		for iz in range(-128, 128):
			lib.spawnBlock(get_tree().root.get_node("world"), (Vector3) (ix, 0, iz))
