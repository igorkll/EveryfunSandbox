extends Node

func blockSound(terrain, soundName, position: Vector3i, blockId=null):
	if blockId == null:
		blockId = terrain.voxel_tool.get_voxel(position)
	
	var item = blockUtils.list_id2obj[blockId]
	if item.has(soundName):
		game.playSound(game.soundList[item.sound_place], terrainUtils.getGlobalPositionFromVoxelPosition(terrain, position))

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, storageData=null):
	blockSound(terrain, "sound_place", position)
	terrainUtils.placeBlock(terrain, position, blockId, rotation, variant, color, storageData)

func destroyBlock(terrain, position: Vector3i, attackLevel=null) -> bool:
	if attackLevel != null:
		var info = blockUtils.getInfo(terrain.voxel_tool.get_voxel(position))
		if info.durability <= 0 || attackLevel < info.durability:
			return false
	
	blockSound(terrain, "sound_destroy", position)
	terrainUtils.destroyBlock(terrain, position)
	return true
