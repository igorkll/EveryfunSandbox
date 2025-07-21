extends Node

static func flat(chunk, position, seed):
	if position.y != 0:
		return
	
	for ix in range(0, chunkManager.chunkSize):
		for iz in range(0, chunkManager.chunkSize):
			blockManager.spawn(position + Vector3(ix, 0, iz), false, "grass", chunk)

static func stone(chunk, position, seed):
	if position.y > 0:
		return
	
	for ix in range(0, chunkManager.chunkSize):
		for iy in range(0, 2):
			for iz in range(0, chunkManager.chunkSize):
				blockManager.spawn(position + Vector3(ix, iy, iz), false, "den", chunk)

static func random(chunk, position, seed):
	for ix in range(0, chunkManager.chunkSize):
		for iy in range(0, chunkManager.chunkSize):
			for iz in range(0, chunkManager.chunkSize):
				blockManager.spawn(position + Vector3(ix, iy, iz), false, blockManager.blockList[randi_range(0, blockManager.blockList.size() - 1)], chunk)
