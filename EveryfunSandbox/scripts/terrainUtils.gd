extends Node

func blockRaycast(position, direction, maxDistance):
	var result = game.terrain.voxel_tool.raycast(position, direction, maxDistance)
	if result:
		return [game.terrain, result]

func placeBlock(position: Vector3i, blockId: int, rotation=0, withSound=true):
	var obj = game.blockList[blockId]
	if obj.has("rotated"):
		rotation = (int(rotation + obj.get("rotationBase", 0)) % 4) + (floor(rotation / 4) * 4)
		
		blockId = obj.rotated[rotation % obj.rotated.size()].id
		obj = game.blockList[blockId]
	
	game.terrain.voxel_tool.set_voxel(position, blockId)
	
	if withSound && obj.has("sound_place"):
		game.playSound(game.soundList[obj.sound_place], game.getGlobalPositionFromVoxelPosition(position), game.terrain)
		
	saves.currentWorldData.interactiveVoxelPositions[position] = blockId
	game.loadBlock(position, blockId)
		
func destroyBlock(position: Vector3i, withSound=true):
	var obj = game.blockList[game.terrain.voxel_tool.get_voxel(position)]
	if withSound && obj.has("sound_destroy"):
		game.playSound(game.soundList[obj.sound_destroy], game.getGlobalPositionFromVoxelPosition(position), game.terrain)
	
	game.unloadBlock(position)
	saves.currentWorldData.interactiveVoxelPositions.erase(position)
	
	game.terrain.voxel_tool.set_voxel(position, 0)

func useBlock(position: Vector3i):
	var qwe = saves.currentWorldData.interactiveVoxelPositions.get(position)
