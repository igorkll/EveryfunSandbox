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
		game.playSound(game.soundList[obj.sound_place], getGlobalPositionFromVoxelPosition(position), game.terrain)
		
	saves.currentWorldData.interactiveVoxelPositions[position] = blockId
	game.loadBlock(position, blockId)
		
func destroyBlock(position: Vector3i, withSound=true):
	var obj = game.blockList[game.terrain.voxel_tool.get_voxel(position)]
	if withSound && obj.has("sound_destroy"):
		game.playSound(game.soundList[obj.sound_destroy], getGlobalPositionFromVoxelPosition(position), game.terrain)
	
	game.unloadBlock(position)
	saves.currentWorldData.interactiveVoxelPositions.erase(position)
	
	game.terrain.voxel_tool.set_voxel(position, 0)

func useBlock(position: Vector3i):
	var qwe = saves.currentWorldData.interactiveVoxelPositions.get(position)

func getVoxelPositionFromGlobalPosition(position: Vector3) -> Vector3i:
	return Vector3i(position - game.terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(position: Vector3i) -> Vector3:
	return game.terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(position: Vector3i) -> bool:
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.8, 0.8, 0.8)
	query.shape = shape
	query.transform = Transform3D(Basis(), getGlobalPositionFromVoxelPosition(position))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	return results.size() == 0
