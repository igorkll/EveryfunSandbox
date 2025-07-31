extends Node

func _ready():
	if not saveManager.exists("default"):
		saveManager.create("default")
	else:
		saveManager.open("default")

var save_timer = 0
var save_per = 5

var updateChunks_per = 2
var updateChunks_timer = 0

func _physics_process(delta):
	updateChunks_timer += delta
	if updateChunks_timer > updateChunks_per:
		chunkManager.updateLoadedChunks([$player.position])
		updateChunks_timer = 0
		
	save_timer += delta
	if save_timer > save_per:
		saveManager.save()
		save_timer = 0
