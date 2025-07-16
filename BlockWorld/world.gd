extends Node

var lib = preload("res://lib.gd")

func _ready():
	for ix in range(-32, 32):
		for iz in range(-32, 32):
			lib.spawnBlock(get_tree().root.get_node("world"), (Vector3) (ix, 0, iz))
