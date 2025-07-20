extends Node

static func flat_world(chunk, position, seed):
	if position.y != 0:
		return
	
	for ix in range(0, chunkManager.chunkSize):
		for iz in range(0, chunkManager.chunkSize):
			blockManager.spawn(position + Vector3(ix, 0, iz), false, "grass", chunk)
