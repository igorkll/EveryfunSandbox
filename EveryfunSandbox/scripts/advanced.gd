extends Node

func explode(position, explosiveLevel):
	if explosiveLevel < 1:
		return
	
	var raycastDistance = explosiveLevel * 2
	var shrapnel = explosiveLevel * 4
	var level = explosiveLevel
	
	var explosionState = {
		"iterations": explosiveLevel * 1
	}
	
	timers.setInterval(func():
		for i in range(shrapnel):
			var result = terrainUtils.blockRaycast(position, funcs.getRandomDirection(), raycastDistance)
			if result:
				if not terrainUtils.callBlock(result[0], result[1].position, "_explode"):
					terrainInteractions.destroyBlock(result[0], result[1].position, level * (1 - (result[1].distance / raycastDistance)))
		explosionState.iterations -= 1
		if explosionState.iterations < 1:
			return true
	, timers.tps_60)
