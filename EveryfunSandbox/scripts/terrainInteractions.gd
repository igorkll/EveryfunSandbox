extends Node

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, storageData=null):
	var item = game.blockList[blockUtils.getVariantBlockId(blockId, rotation, variant, color)]
	if item.has("sound_place"):
		game.playSound(game.soundList[item.sound_place], terrainUtils.getGlobalPositionFromVoxelPosition(terrain, position))
	
	terrainUtils.placeBlock(terrain, position, blockId, rotation, variant, color, storageData)

func destroyBlock(terrain, position: Vector3i):
	var item = game.blockList[terrain.voxel_tool.get_voxel(position)]
	if item.has("sound_destroy"):
		game.playSound(game.soundList[item.sound_destroy], terrainUtils.getGlobalPositionFromVoxelPosition(terrain, position))
	
	terrainUtils.destroyBlock(terrain, position)
