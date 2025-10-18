extends Node

func explode(position, explosiveLevel):
	if explosiveLevel < 1:
		return
	
	var raycastDistance = explosiveLevel * 2
	var shrapnel = explosiveLevel * 4
	
	var explosionState = {
		"iterations": explosiveLevel * 1
	}
	
	timers.setInterval(func():
		for i in range(shrapnel):
			var result = terrainUtils.blockRaycast(position, funcs.getRandomDirection(), raycastDistance)
			if result:
				if not terrainUtils.callBlock(result[0], result[1].position, "_explode"):
					terrainUtils.destroyBlock(result[0], result[1].position)
		explosionState.iterations -= 1
		if explosionState.iterations < 1:
			return true
	, 0.1)
