extends Node

var game = preload("res://scripts/game.gd")

func _ready():
	for ix in range(-32, 32):
		for iz in range(-32, 32):
			game.placeBlock(get_tree().root.get_node("world"), (Vector3) (ix, 0, iz))
	
	for iy in range(32):
		game.spawnBlock(get_tree().root.get_node("world"), (Vector3) (0, 10 + iy, 0))
