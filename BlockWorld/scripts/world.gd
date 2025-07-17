extends Node

var game = preload("res://scripts/game.gd")

func _ready():
	for ix in range(-64, 64):
		for iz in range(-64, 64):
			game.placeBlock(get_tree().root.get_node("world"), (Vector3) (ix, 0, iz), preload("res://blocks/grass/script.gd").new())
	
	for iy in range(32):
		game.spawnBlock(get_tree().root.get_node("world"), (Vector3) (15, 10 + iy, 0))
