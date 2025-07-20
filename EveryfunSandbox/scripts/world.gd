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

var update_chunks_per = 2
var update_chunks_timer = 0

func _physics_process(delta):
	update_chunks_timer += delta
	if update_chunks_timer > update_chunks_per:
		chunkManager.updateLoadedChunks([$player.position])
		
	save_timer += delta
	if save_timer > save_per:
		saveManager.save()
		save_timer = 0
