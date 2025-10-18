extends Node

func explode(position, explosiveLevel):
	if explosiveLevel < 1:
		return
	
	var raycastDistance = explosiveLevel * 2
	var iterations = explosiveLevel * 1
	var shrapnel = explosiveLevel * 4
	
	timers.setInterval(func():
		for i in range(shrapnel):
			var result = terrainUtils.blockRaycast(position, funcs.getRandomDirection(), raycastDistance)
			if result:
				terrainUtils.destroyBlock(result[0], result[1].position)
		iterations -= 1
		if iterations < 1:
			return true
	, 0.1)
