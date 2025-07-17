extends Node

var game = preload("res://scripts/game.gd")

func _ready():
	for ix in range(-32, 32):
		for iz in range(-32, 32):
			game.spawnBlock($World, (Vector3) (ix, 0, iz), false, preload("res://blocks/grass/script.gd"))
	
	for iy in range(32):
		game.spawnBlock($World, (Vector3) (0, 10 + iy, 0), true, preload("res://blocks/pig/script.gd"))
