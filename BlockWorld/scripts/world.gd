extends Node

func _ready():
	if not saveManager.exists("default"):
		saveManager.create("default")
		
		for iy in range(32):
			blockManager.spawn((Vector3) (0, 10 + iy * 2, 10), null, true, "pig")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, 0), null, true, "tnt")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, 10), null, true, "den")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, -10), null, true, "rainbow")
			
			blockManager.spawn((Vector3) (0, 10 + iy * 2, 12), null, false, "pig")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, 0), null, false, "tnt")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, 12), null, false, "den")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, -12), null, false, "rainbow")
			
		for ix in range(-32, 32):
			for iz in range(-32, 32):
				blockManager.spawn((Vector3) (ix, 0, iz), null, false, "grass")
				
		saveManager.save()
	else:
		saveManager.open("default")
