extends Node

func blockRaycast(position, direction, maxDistance):
	var terrain = game.terrain
	
	var result = terrain.voxel_tool.raycast(position, direction, maxDistance)
	if result:
		return [terrain, result]
		
func attachBlockChild(terrain, position, child):
	if not terrain.blockChildren.has(position):
		terrain.blockChildren[position] = []
	terrain.blockChildren[position].append(child)
	terrain.add_child(child)
	
func getBlockChildren(terrain, position):
	if terrain.blockChildren.has(position):
		return terrain.blockChildren[position]
	else:
		return []

func loadBlock(terrain, position: Vector3i, blockId: int, storageData=null):
	if terrain.blockChildren.has(position):
		return
	
	if storageData == null:
		storageData = {}
	
	var obj = game.blockList[blockId]
	var childPos = Vector3(position) + Vector3(0.5, 0.5, 0.5)
	
	if obj.has("script"):
		var script = game.loadResource(obj.script)
		var node = script.new()
		
		node.position = childPos
		node.storageData = storageData
		node.scriptData = obj.get("script_data", {})
		
		node.voxelTerrain = terrain
		node.voxelPosition = position
		node.voxelRotation = 0
		node.voxelVariant = obj.currentVariant
		node.voxelDirection = Vector3i(1, 0, 0)
		node.voxelDirectionUp = Vector3i(0, 1, 0)
		
		node.voxelBaseBlockId = obj.baseId
		node.voxelBaseBlockItem = game.blockList[obj.baseId]
		
		node.voxelBlockId = blockId
		node.voxelBlockItem = obj
		
		node.multiblock = Vector3i(1, 1, 1)
		node.multiblockRelative = node.multiblock
		
		if obj.has("rotation"):
			node.rotation_degrees = obj.rotation.r
			node.voxelRotation = obj.currentRotation
			node.voxelDirection = obj.rotation.d
			node.voxelDirectionUp = obj.rotation.u
		
		attachBlockChild(terrain, position, node)
	
func isInteractive(terrain, blockId: int) -> bool:
	var obj = game.blockList[blockId]
	return obj.has("script")
		
func unloadBlock(terrain, position: Vector3i):
	if terrain.blockChildren.has(position):
		for obj in terrain.blockChildren[position]:
			obj.queue_free()
		terrain.blockChildren.erase(position)

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, withSound=true, storageData=null):
	if storageData == null:
		storageData = {}
	
	blockId = game.getVariantBlockId(blockId, rotation, variant)
	var item = game.blockList[blockId]
	
	terrain.voxel_tool.set_voxel(position, blockId)
	
	if withSound && item.has("sound_place"):
		game.playSound(game.soundList[item.sound_place], getGlobalPositionFromVoxelPosition(terrain, position))
	
	if isInteractive(terrain, blockId):
		saves.regInteractiveVoxel(terrain, position, blockId, storageData)
	
	if saves.isInteractiveChunkBlockLoaded(position):
		loadBlock(terrain, position, blockId, storageData)

func destroyBlock(terrain, position: Vector3i, withSound=true):
	var obj = game.blockList[terrain.voxel_tool.get_voxel(position)]
	if withSound && obj.has("sound_destroy"):
		game.playSound(game.soundList[obj.sound_destroy], getGlobalPositionFromVoxelPosition(terrain, position))
	
	unloadBlock(terrain, position)
	saves.regInteractiveVoxel(terrain, position, null)
	
	terrain.voxel_tool.set_voxel(position, 0)

func useBlock(terrain, position: Vector3i) -> bool:
	var children = getBlockChildren(terrain, position)
	var used = false
	for child in children:
		if child.has_method("_use"):
			child.call("_use")
			used = true
	return used
	
func canUseBlock(terrain, position: Vector3i) -> bool:
	var children = getBlockChildren(terrain, position)
	for child in children:
		if child.has_method("_use"):
			return true
	return false

func getVoxelPositionFromGlobalPosition(terrain, position: Vector3) -> Vector3i:
	return funcs.vec3_to_vec3i_down(position - terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(terrain, position: Vector3i) -> Vector3:
	return terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(terrain, position: Vector3i) -> bool:
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.8, 0.8, 0.8)
	query.shape = shape
	query.transform = Transform3D(Basis(), getGlobalPositionFromVoxelPosition(terrain, position))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	return results.size() == 0
