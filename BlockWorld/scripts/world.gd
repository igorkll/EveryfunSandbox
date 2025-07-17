extends Node

func _ready():
	for iy in range(32):
		game.spawnBlock($World, (Vector3) (0, 10 + iy, 0), true, preload("res://blocks/pig/script.gd"))
		
	for ix in range(-32, 32):
		for iz in range(-32, 32):
			game.spawnBlock($World, (Vector3) (ix, 0, iz), false, preload("res://blocks/grass/script.gd"))
