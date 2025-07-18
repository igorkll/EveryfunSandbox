extends Node

func _ready():
	for iy in range(32):
		blockManager.spawn((Vector3) (0, 10 + iy * 2, 10), true, preload("res://blocks/pig/script.gd"))
		blockManager.spawn((Vector3) (10, 10 + iy * 2, 0), true, preload("res://blocks/tnt/script.gd"))
		blockManager.spawn((Vector3) (10, 10 + iy * 2, 10), true, preload("res://blocks/den/script.gd"))
		blockManager.spawn((Vector3) (10, 10 + iy * 2, -10), true, preload("res://blocks/rainbox/script.gd"))
		
		blockManager.spawn((Vector3) (0, 10 + iy * 2, 12), false, preload("res://blocks/pig/script.gd"))
		blockManager.spawn((Vector3) (12, 10 + iy * 2, 0), false, preload("res://blocks/tnt/script.gd"))
		blockManager.spawn((Vector3) (12, 10 + iy * 2, 12), false, preload("res://blocks/den/script.gd"))
		blockManager.spawn((Vector3) (12, 10 + iy * 2, -12), false, preload("res://blocks/rainbox/script.gd"))
		
	for ix in range(-32, 32):
		for iz in range(-32, 32):
			blockManager.spawn((Vector3) (ix, 0, iz), false, preload("res://blocks/grass/script.gd"))
			
	saveManager.save("default")
