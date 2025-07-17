extends Node

var game = preload("res://scripts/game.gd")

func _ready():
	for ix in range(-64, 64):
		for iz in range(-64, 64):
			game.spawnBlock(get_tree().root.get_node("world"), (Vector3) (ix, 0, iz), false, preload("res://blocks/grass/script.gd"))
	
	for iy in range(32):
		game.spawnBlock(get_tree().root.get_node("world"), (Vector3) (0, 10 + iy, 0), true, preload("res://blocks/grass/script.gd"))
