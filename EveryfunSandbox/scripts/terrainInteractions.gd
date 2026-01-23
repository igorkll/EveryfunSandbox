extends Node

func blockSound(terrain, soundName, position: Vector3i, blockId=null):
	if blockId == null:
		blockId = terrain.voxel_tool.get_voxel(position)
	
	var item = blockUtils.list_id2obj[blockId]
	if item.has(soundName):
		game.playSound(game.soundList[item.sound_place], terrainUtils.getGlobalPositionFromVoxelPosition(terrain, position))

func attackCheck(blockId: int, attackLevel: float):
	var info = blockUtils.getInfo(blockId)
	return info.durability > 0 && attackLevel > 0 && (attackLevel >= info.durability || randf() < ((attackLevel / info.durability) * consts.chance_multiplier_to_destroy_a_block_of_greater_strength))

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, storageData=null):
	blockSound(terrain, "sound_place", position, blockId)
	terrainUtils.placeBlock(terrain, position, blockId, rotation, variant, color, storageData)

func destroyBlock(terrain, position: Vector3i, attackLevel=null) -> bool:
	if attackLevel != null && not attackCheck(terrain.voxel_tool.get_voxel(position), attackLevel):
		return false
	
	blockSound(terrain, "sound_destroy", position)
	terrainUtils.destroyBlock(terrain, position)
	return true
	
func hitBlock(terrain, position: Vector3i, hitInfo, delta) -> bool:
	blockSound(terrain, "sound_hit", position)
	
	if not hitInfo.has("timer") or hitInfo.terrain != terrain or hitInfo.position != position:
		hitInfo["timer"] = 0
		hitInfo["terrain"] = terrain
		hitInfo["position"] = position
	
	hitInfo["timer"] += delta
	
	var blockDestroyTime = terrainUtils.getBlockInfo(terrain, position).durability * consts.one_durability_destroy_seconds
	return hitInfo["timer"] > blockDestroyTime
