extends Node

func _ready():
	if not saveManager.exists("default"):
		saveManager.create("default")
	else:
		saveManager.open("default")
	
	for chunk in $world.get_node("chunks").get_children():
		chunk.updateMesh()
		
	blockManager.autoChunkUpdate = true
	

var save_timer = 0
var save_per = 5

func _physics_process(delta):
	save_timer += delta
	if save_timer > save_per:
		saveManager.save()
		save_timer = 0
