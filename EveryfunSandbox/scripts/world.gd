extends Node

func _ready():
	skyManager.setTime(0.5)
	
	if not saveManager.exists("default"):
		saveManager.create("default")
		
		for iy in range(32):
			blockManager.spawn((Vector3) (0, 10 + iy * 2, 10), true, "pig")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, 0), true, "tnt")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, 10), true, "den")
			blockManager.spawn((Vector3) (10, 10 + iy * 2, -10), true, "rainbow")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, -12), true, "gipno_pig")
			
			blockManager.spawn((Vector3) (0, 10 + iy * 2, 12), false, "pig")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, 0), false, "tnt")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, 12), false, "den")
			blockManager.spawn((Vector3) (12, 10 + iy * 2, -12), false, "rainbow")
			
		for ix in range(-64, 32):
			for iz in range(-32, 32):
				blockManager.spawn((Vector3) (ix, 0, iz), false, "grass")
				
		saveManager.save()
	else:
		saveManager.open("default")
	
	for chunk in $world.get_node("chunks").get_children():
		chunk.updateMesh()
	

var save_timer = 0
var save_per = 5

func _physics_process(delta):
	save_timer += delta
	if save_timer > save_per:
		saveManager.save()
		save_timer = 0
