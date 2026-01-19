extends baseblock

func _use():
	var pos = voxelPosition + Vector3i(0, 1, 0)
	terrainUtils.setColor(voxelTerrain, pos, (terrainUtils.getColor(voxelTerrain, pos) + 1) % terrainUtils.getColorsCount(voxelTerrain, pos))
