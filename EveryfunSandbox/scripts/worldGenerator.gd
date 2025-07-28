extends Node

static func flat(chunk, position, seed):
	if position.y != 0:
		return false
	
	for ix in range(0, chunkManager.chunkSize):
		for iz in range(0, chunkManager.chunkSize):
			blockManager.wspawn(position + Vector3(ix, 0, iz), false, "grass", chunk)
			
	return true

static func stone(chunk, position, seed):
	if position.y > 0:
		return false
	
	for ix in range(0, chunkManager.chunkSize):
		for iy in range(0, chunkManager.chunkSize):
			for iz in range(0, chunkManager.chunkSize):
				blockManager.wspawn(position + Vector3(ix, iy, iz), false, "grass", chunk)
				
	return true

static func random(chunk, position, seed):
	var blockedPosition
	if position.x == 0 && position.y == 0 && position.z == 0:
		blockManager.wspawn(position, false, "grass", chunk)
		blockedPosition = position

	for iz in range(0, chunkManager.chunkSize):	
		for iy in range(0, chunkManager.chunkSize):
			for ix in range(0, chunkManager.chunkSize):
				var pos = position + Vector3(ix, iy, iz)
				if randi_range(0, 1000) == 0 && pos != blockedPosition:
					blockManager.wspawn(pos, false, blockManager.blockList[randi_range(0, blockManager.blockList.size() - 1)], chunk)
					
	return true
